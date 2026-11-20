class_name AttackData
extends Resource
## Frame data for ONE move. One resource instance per move, assigned in the inspector.
## Rule of thumb: stun severity scales with commitment (startup + recovery).

enum StunType { NONE, LIGHT, HEAVY }

@export_group("Identity")
@export var display_name: String = "Jab"

@export_group("Frame Data")
@export var startup_frames: int = 5
@export var active_frames: int = 3
@export var recovery_frames: int = 12
@export var hitstun_frames: int = 14    # normal hitstun (non-stun hits)
@export var blockstun_frames: int = 8

@export_group("Payoff")
@export var damage: int = 5
@export var stun_type: StunType = StunType.NONE
@export var stun_duration_frames: int = 0   # used when stun_type != NONE

@export_group("Hitbox")
@export var hitbox_offset: Vector2 = Vector2(60, -40)   # relative to fighter, facing-adjusted
@export var hitbox_size: Vector2 = Vector2(70, 40)

@export_group("Knockback")
@export var pushback_attacker: Vector2 = Vector2(-40, 0)
@export var pushback_defender: Vector2 = Vector2(120, 0)
@export var knockdown: bool = false

@export_group("Links")
## Names of moves this attack can be cancelled into during active/recovery
## (future: light-stun link windows). Empty = no cancels.
@export var cancellable_into: Array[StringName] = []

@export_group("Throw")
@export var is_throw: bool = false          # throws use grab range instead of hitbox
@export var grab_range: float = 80.0


func total_frames() -> int:
	return startup_frames + active_frames + recovery_frames
