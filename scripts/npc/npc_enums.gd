class_name NPCEnums
extends RefCounted

enum Role {
	CIVIL,
	SOLDIER,
	HOSTILE,
}

enum Faction {
	PLAYER,
	ENEMY,
	NEUTRAL,
}

enum State {
	IDLE,
	SELECTED,
	MOVING,
	FOLLOWING,
	BLOCKED,
	HOLDING_POSITION,
}

enum OrderType {
	NONE,
	MOVE_TO_POSITION,
	STOP,
	HOLD_POSITION,
	PATROL,
	FOLLOW_TARGET,
	CLEAR_QUEUE,
	ASSIST_BUILD,
	GATHER_RESOURCE,
	FORCE_DROP,
	REPAIR,
	REPAIR_UNDER_FIRE,
	GARRISON,
	ATTACK_MOVE,
	FOCUS_FIRE,
	FIRE_AT_WILL,
	HOLD_FIRE,
	VOLLEY_FIRE,
	FORM_SHIELD_WALL,
	BRACE_PIKES,
	MAN_SIEGE_RAM,
	SCALE_WALLS,
	SAP_FOUNDATION,
	POUR_MURDER_HOLES,
	SALLY_OUT,
	FOLLOW_PLAYER,
}

enum OrderStatus {
	PENDING,
	RUNNING,
	COMPLETED,
	FAILED,
	CANCELLED,
	UNSUPPORTED,
	PARTIAL,
}


static func role_to_string(value: int) -> String:
	match value:
		Role.CIVIL:
			return "CIVIL"
		Role.SOLDIER:
			return "SOLDIER"
		Role.HOSTILE:
			return "HOSTILE"
		_:
			return "UNKNOWN_ROLE"


static func faction_to_string(value: int) -> String:
	match value:
		Faction.PLAYER:
			return "PLAYER"
		Faction.ENEMY:
			return "ENEMY"
		Faction.NEUTRAL:
			return "NEUTRAL"
		_:
			return "UNKNOWN_FACTION"


static func state_to_string(value: int) -> String:
	match value:
		State.IDLE:
			return "IDLE"
		State.SELECTED:
			return "SELECTED"
		State.MOVING:
			return "MOVING"
		State.FOLLOWING:
			return "FOLLOWING"
		State.BLOCKED:
			return "BLOCKED"
		State.HOLDING_POSITION:
			return "HOLDING_POSITION"
		_:
			return "UNKNOWN_STATE"


static func order_type_to_string(value: int) -> String:
	match value:
		OrderType.NONE:
			return "NONE"
		OrderType.MOVE_TO_POSITION:
			return "MOVE_TO_POSITION"
		OrderType.STOP:
			return "STOP"
		OrderType.HOLD_POSITION:
			return "HOLD_POSITION"
		OrderType.PATROL:
			return "PATROL"
		OrderType.FOLLOW_TARGET:
			return "FOLLOW_TARGET"
		OrderType.CLEAR_QUEUE:
			return "CLEAR_QUEUE"
		OrderType.ASSIST_BUILD:
			return "ASSIST_BUILD"
		OrderType.GATHER_RESOURCE:
			return "GATHER_RESOURCE"
		OrderType.FORCE_DROP:
			return "FORCE_DROP"
		OrderType.REPAIR:
			return "REPAIR"
		OrderType.REPAIR_UNDER_FIRE:
			return "REPAIR_UNDER_FIRE"
		OrderType.GARRISON:
			return "GARRISON"
		OrderType.ATTACK_MOVE:
			return "ATTACK_MOVE"
		OrderType.FOCUS_FIRE:
			return "FOCUS_FIRE"
		OrderType.FIRE_AT_WILL:
			return "FIRE_AT_WILL"
		OrderType.HOLD_FIRE:
			return "HOLD_FIRE"
		OrderType.VOLLEY_FIRE:
			return "VOLLEY_FIRE"
		OrderType.FORM_SHIELD_WALL:
			return "FORM_SHIELD_WALL"
		OrderType.BRACE_PIKES:
			return "BRACE_PIKES"
		OrderType.MAN_SIEGE_RAM:
			return "MAN_SIEGE_RAM"
		OrderType.SCALE_WALLS:
			return "SCALE_WALLS"
		OrderType.SAP_FOUNDATION:
			return "SAP_FOUNDATION"
		OrderType.POUR_MURDER_HOLES:
			return "POUR_MURDER_HOLES"
		OrderType.SALLY_OUT:
			return "SALLY_OUT"
		OrderType.FOLLOW_PLAYER:
			return "FOLLOW_PLAYER"
		_:
			return "UNKNOWN_ORDER"


static func order_status_to_string(value: int) -> String:
	match value:
		OrderStatus.PENDING:
			return "PENDING"
		OrderStatus.RUNNING:
			return "RUNNING"
		OrderStatus.COMPLETED:
			return "COMPLETED"
		OrderStatus.FAILED:
			return "FAILED"
		OrderStatus.CANCELLED:
			return "CANCELLED"
		OrderStatus.UNSUPPORTED:
			return "UNSUPPORTED"
		OrderStatus.PARTIAL:
			return "PARTIAL"
		_:
			return "UNKNOWN_STATUS"
