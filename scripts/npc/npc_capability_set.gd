class_name NPCCapabilitySet
extends Resource

@export var can_move: bool = true
@export var can_build: bool = true
@export var can_gather: bool = false
@export var can_deposit: bool = false
@export var can_repair: bool = false
@export var can_attack: bool = false
@export var can_use_ranged_attack: bool = false
@export var can_garrison: bool = false
@export var can_form_shield_wall: bool = false
@export var can_brace_pikes: bool = false
@export var can_operate_siege: bool = false
@export var can_scale_walls: bool = false
@export var can_sap_foundation: bool = false
@export var can_use_murder_holes: bool = false
@export var can_sally_out: bool = false


func configure_for_role(role: int) -> void:
	can_move = false
	can_build = false
	can_gather = false
	can_deposit = false
	can_repair = false
	can_attack = false
	can_use_ranged_attack = false
	can_garrison = false
	can_form_shield_wall = false
	can_brace_pikes = false
	can_operate_siege = false
	can_scale_walls = false
	can_sap_foundation = false
	can_use_murder_holes = false
	can_sally_out = false

	match role:
		NPCEnums.Role.CIVIL:
			can_move = true
			can_build = true
			can_gather = true
			can_deposit = true
			can_repair = true
			can_attack = false
		NPCEnums.Role.SOLDIER:
			can_move = true
			can_build = false
			can_attack = true
			can_use_ranged_attack = false
			can_form_shield_wall = true
			can_brace_pikes = true
			can_garrison = true
		NPCEnums.Role.HOSTILE:
			can_move = true
			can_build = false
			can_attack = true


func supports(order_type: int) -> bool:
	match order_type:
		NPCEnums.OrderType.MOVE_TO_POSITION, NPCEnums.OrderType.STOP, NPCEnums.OrderType.HOLD_POSITION, NPCEnums.OrderType.PATROL, NPCEnums.OrderType.FOLLOW_TARGET, NPCEnums.OrderType.FOLLOW_PLAYER, NPCEnums.OrderType.CLEAR_QUEUE, NPCEnums.OrderType.ATTACK_MOVE:
			return can_move
		NPCEnums.OrderType.ASSIST_BUILD:
			return can_build
		NPCEnums.OrderType.GATHER_RESOURCE:
			return can_gather
		NPCEnums.OrderType.FORCE_DROP:
			return can_deposit
		NPCEnums.OrderType.REPAIR, NPCEnums.OrderType.REPAIR_UNDER_FIRE:
			return can_repair
		NPCEnums.OrderType.FIRE_AT_WILL, NPCEnums.OrderType.HOLD_FIRE, NPCEnums.OrderType.FOCUS_FIRE:
			return can_attack
		NPCEnums.OrderType.VOLLEY_FIRE:
			return can_use_ranged_attack
		NPCEnums.OrderType.GARRISON:
			return can_garrison
		NPCEnums.OrderType.FORM_SHIELD_WALL:
			return can_form_shield_wall
		NPCEnums.OrderType.BRACE_PIKES:
			return can_brace_pikes
		NPCEnums.OrderType.MAN_SIEGE_RAM:
			return can_operate_siege
		NPCEnums.OrderType.SCALE_WALLS:
			return can_scale_walls
		NPCEnums.OrderType.SAP_FOUNDATION:
			return can_sap_foundation
		NPCEnums.OrderType.POUR_MURDER_HOLES:
			return can_use_murder_holes
		NPCEnums.OrderType.SALLY_OUT:
			return can_sally_out
		_:
			return false
