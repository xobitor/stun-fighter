class_name FighterTuning
extends Resource
## Per-character movement/physics identity. Separate from AttackData on purpose:
## different tuning cadence (feel passes vs. frame-data balance).

@export_group("Ground Movement")
@export var walk_speed: float = 300.0
@export var back_walk_speed: float = 240.0      # walking away is slower (footsies)
@export var dash_speed: float = 600.0
@export var dash_duration_frames: int = 14
@export var dash_recovery_frames: int = 10      # punishable commitment

@export_group("Jump (design pillar: slow, readable, risky arcs)")
@export var jump_velocity: float = -700.0       # negative = up in Godot
@export var gravity: float = 1600.0
@export var jump_squat_frames: int = 4          # telegraph before leaving ground
@export var max_fall_speed: float = 1200.0
@export var air_control: float = 0.15           # near-zero: committed arcs

@export_group("Defense")
@export var max_health: int = 1000
@export var mash_escape_frames: int = 30        # light-stun mash-out baseline (M2)

@export_group("Body")
@export var body_size: Vector2 = Vector2(60, 160)
