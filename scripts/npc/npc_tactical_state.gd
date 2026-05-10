class_name NPCTacticalState
extends Resource

const IDLE := "idle"
const MOVING := "moving"
const FOLLOWING := "following"
const HOLDING_POSITION := "holding_position"
const ASSISTING_BUILD := "assisting_build"
const ATTACK_MOVE_PENDING := "attack_move_pending"
const FIRE_AT_WILL := "fire_at_will"
const HOLD_FIRE := "hold_fire"
const SHIELD_WALL_PARTIAL := "shield_wall_partial"
const BRACED_PIKES := "braced_pikes"
const GARRISON_PENDING := "garrison_pending"
const UNSUPPORTED_ORDER := "unsupported_order"

@export var state: String = IDLE
@export var posture: String = ""
@export var blocks_auto_chase: bool = false
@export var blocks_auto_movement: bool = false
@export var speed_multiplier: float = 1.0
@export var last_reason: String = ""


func set_state(new_state: String, reason: String = "") -> void:
	state = new_state
	last_reason = reason


func reset_movement_modifiers() -> void:
	blocks_auto_chase = false
	blocks_auto_movement = false
	speed_multiplier = 1.0
	posture = ""
