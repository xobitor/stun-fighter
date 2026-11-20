class_name Fighter
extends CharacterBody2D
## Project Grounded — fighter state machine skeleton (M1 scope).
## The state machine decides WHAT happens; frame counters decide WHEN;
## the data resources decide HOW MUCH.

enum State {
	IDLE, WALK_F, WALK_B, DASH,
	JUMP_SQUAT, AIRBORNE, LANDING,
	BLOCK, BLOCKSTUN,
	ATTACK_STARTUP, ATTACK_ACTIVE, ATTACK_RECOVERY,
	HITSTUN,
	# Stun states exist from day one even if they behave like HITSTUN for now.
	LIGHT_STUN, HEAVY_STUN,
	KNOCKDOWN,
	THROW_ATTEMPT, THROWN,
}

const GameCfg = preload("res://scripts/game_config.gd")

@export var tuning: FighterTuning
@export var moves: Dictionary = {}   # StringName -> AttackData, assigned in inspector
@export var player_prefix: StringName = &"p1"

var state: State = State.IDLE
var state_frames: int = 0            # frames spent in current state — reset on every transition
var facing: int = 1                  # 1 = right, -1 = left; always face the opponent
var current_attack: AttackData = null
var health: int = 0

@onready var opponent: Fighter = null          # wired by Main after instancing
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox


func _ready() -> void:
	health = tuning.max_health
	hitbox.monitoring = false          # hitboxes only exist during Active frames


# ---------------------------------------------------------------- simulation

func _physics_process(_delta: float) -> void:
	state_frames += 1
	_tick_state()
	_apply_gravity_and_motion()
	_apply_facing()
	_update_hitbox_state()
	_debug_draw()


# ---------------------------------------------------------------- state logic

func _tick_state() -> void:
	match state:
		State.IDLE, State.WALK_F, State.WALK_B:
			_do_ground_movement()
			_try_start_actions()
		State.DASH:
			if state_frames >= tuning.dash_duration_frames:
				_change_state(State.IDLE)
		State.JUMP_SQUAT:
			if state_frames >= tuning.jump_squat_frames:
				velocity.y = tuning.jump_velocity
				_change_state(State.AIRBORNE)
		State.AIRBORNE:
			if is_on_floor():
				_change_state(State.LANDING)
		State.LANDING:
			if state_frames >= 4:   # landing recovery; tune in feel pass
				_change_state(State.IDLE)
		State.BLOCK:
			if not Input.is_action_pressed(player_prefix + &"_block"):
				_change_state(State.IDLE)
		State.BLOCKSTUN:
			if state_frames >= current_attack.blockstun_frames:
				_change_state(State.BLOCK if Input.is_action_pressed(player_prefix + &"_block") else State.IDLE)
		State.ATTACK_STARTUP:
			if state_frames >= current_attack.startup_frames:
				_change_state(State.ATTACK_ACTIVE)
		State.ATTACK_ACTIVE:
			_tick_hitbox()
			if state_frames >= current_attack.active_frames:
				_change_state(State.ATTACK_RECOVERY)
		State.ATTACK_RECOVERY:
			if state_frames >= current_attack.recovery_frames:
				_change_state(State.IDLE)
		State.HITSTUN:
			if state_frames >= current_attack.hitstun_frames:
				_change_state(State.IDLE)
		# M2 placeholders: LIGHT_STUN / HEAVY_STUN get mash-out, reversal,
		# natural recovery/cover-up terminators. Same shape as HITSTUN for now.
		State.LIGHT_STUN, State.HEAVY_STUN:
			if state_frames >= current_attack.stun_duration_frames:
				_change_state(State.IDLE)
		State.KNOCKDOWN:
			if state_frames >= 30:  # okizeme rules TBD — design doc open question #2
				_change_state(State.IDLE)


func _do_ground_movement() -> void:
	var axis := Input.get_axis(player_prefix + &"_left", player_prefix + &"_right")
	if is_zero_approx(axis):
		velocity.x = 0.0
		if state != State.IDLE:
			_change_state(State.IDLE)
	else:
		var forward := axis * facing > 0.0
		velocity.x = axis * (tuning.walk_speed if forward else tuning.back_walk_speed)
		_change_state(State.WALK_F if forward else State.WALK_B)


func _try_start_actions() -> void:
	if Input.is_action_just_pressed(player_prefix + &"_block"):
		_change_state(State.BLOCK)
	elif Input.is_action_just_pressed(player_prefix + &"_dash"):
		_change_state(State.DASH)
	elif Input.is_action_just_pressed(player_prefix + &"_jump"):
		_change_state(State.JUMP_SQUAT)
	elif Input.is_action_just_pressed(player_prefix + &"_light"):
		_start_attack(&"light")
	elif Input.is_action_just_pressed(player_prefix + &"_heavy"):
		_start_attack(&"heavy")
	elif Input.is_action_just_pressed(player_prefix + &"_throw"):
		_change_state(State.THROW_ATTEMPT)


func _start_attack(move_name: StringName) -> void:
	if not moves.has(move_name):
		return
	current_attack = moves[move_name]
	_change_state(State.ATTACK_STARTUP)


# ---------------------------------------------------------------- transitions

## The ONLY way to change state. All guards live here so impossible states
## (attacking while stunned, etc.) cannot happen.
func _change_state(new_state: State) -> void:
	if not _can_transition_to(new_state):
		return
	state = new_state
	state_frames = 0
	match new_state:
		State.AIRBORNE, State.ATTACK_STARTUP, State.DASH:
			pass  # per-state entry effects go here later (sfx, particles)


func _can_transition_to(new_state: State) -> bool:
	# Stun/knockdown states ignore player input transitions entirely;
	# only natural recovery can end them.
	if state in locked_states() or state == State.BLOCKSTUN:
		return new_state == State.IDLE

	# Attack phases: only their own progression is allowed.
	match state:
		State.ATTACK_STARTUP:
			return new_state == State.ATTACK_ACTIVE
		State.ATTACK_ACTIVE:
			return new_state == State.ATTACK_RECOVERY
		State.ATTACK_RECOVERY:
			return new_state == State.IDLE

	return true


# ---------------------------------------------------------------- combat

func _tick_hitbox() -> void:
	# Enabled only during Active frames; one hit per attack instance.
	# Overlap resolution -> opponent.receive_hit(current_attack, self) goes here (M1 step 4).
	pass


func receive_hit(attack: AttackData, attacker: Fighter) -> void:
	# Block check: holding block + facing the attacker -> blockstun + pushback.
	if state == State.BLOCK and signf(attacker.global_position.x - global_position.x) == -facing:
		velocity.x = attack.pushback_attacker.x * -1.0
		current_attack = attack
		_change_state(State.BLOCKSTUN)
		return
	health -= attack.damage
	current_attack = attack
	match attack.stun_type:
		AttackData.StunType.LIGHT:
			_change_state(State.LIGHT_STUN)
		AttackData.StunType.HEAVY:
			_change_state(State.HEAVY_STUN)
		_:
			_change_state(State.KNOCKDOWN if attack.knockdown else State.HITSTUN)
	# TODO: pushback, hitstop (global freeze frames — a Main-level concern)


# ---------------------------------------------------------------- helpers

func _apply_gravity_and_motion() -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + tuning.gravity * (1.0 / GameCfg.PHYSICS_TICK),
				tuning.max_fall_speed)
	velocity.x *= 0.85 if state in locked_states() else 1.0   # friction while in stun
	move_and_slide()


func _apply_facing() -> void:
	if opponent and state in [State.IDLE, State.WALK_F, State.WALK_B, State.BLOCK]:
		facing = 1 if opponent.global_position.x >= global_position.x else -1


func _update_hitbox_state() -> void:
	hitbox.monitoring = state == State.ATTACK_ACTIVE


func locked_states() -> Array[State]:
	return [State.HITSTUN, State.LIGHT_STUN, State.HEAVY_STUN, State.KNOCKDOWN, State.THROWN]


func _debug_draw() -> void:
	if not GameCfg.DEBUG_DRAW_HITBOXES:
		return
	queue_redraw()
	# Draw hit/hurtbox outlines in _draw() — implement when the scene exists.
