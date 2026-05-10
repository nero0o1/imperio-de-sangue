class_name NPCHouse
extends StaticBody3D

signal creation_requested(source: NPCHouse, actor: Node)
signal npc_created(npc: NPCBase)

@export var house_name: String = "Casa"
@export var npc_scene: PackedScene
@export var spawn_parent_path: NodePath = NodePath("..")
@export var max_spawned_npcs: int = 3
@export var spawn_radius: float = 2.0
@export var creation_enabled: bool = true

var spawned_count: int = 0
var _created_npcs: Array[NPCBase] = []
var _next_npc_index: int = 1


func _ready() -> void:
	add_to_group("npc_house")
	print("[NPC] Casa de criacao pronta: %s limite=%d." % [house_name, max_spawned_npcs])


func interact(actor: Node = null) -> void:
	if not creation_enabled:
		print("[NPC] Casa Civil ainda nao esta construida. Criacao de civis bloqueada.")
		return

	print("[NPC] Casa de criacao interagida: %s por %s." % [
		house_name,
		str(actor.name) if actor != null else "unknown",
	])
	creation_requested.emit(self, actor)


func can_create_npc() -> bool:
	_prune_invalid_npcs()
	return creation_enabled and npc_scene != null and spawned_count < max_spawned_npcs


func create_npc(actor: Node = null) -> NPCBase:
	_prune_invalid_npcs()
	if not can_create_npc():
		print("[NPC] Criacao de civil bloqueada em %s. npc_scene=%s spawned=%d max=%d." % [
			house_name,
			str(npc_scene != null),
			spawned_count,
			max_spawned_npcs,
		])
		return null

	var instance := npc_scene.instantiate()
	var npc := instance as NPCBase
	if npc == null:
		print("[NPC] Criacao de civil falhou: cena configurada nao instancia NPCBase.")
		instance.queue_free()
		return null

	var spawn_parent := _get_spawn_parent()
	if spawn_parent == null or not is_instance_valid(spawn_parent):
		print("[NPC] Criacao de civil falhou: parent de spawn invalido em %s." % house_name)
		npc.queue_free()
		return null

	npc.name = "Civil%d" % _next_npc_index
	npc.npc_name = "Civil %d" % _next_npc_index
	_next_npc_index += 1

	spawn_parent.add_child(npc)
	spawned_count += 1
	_created_npcs.append(npc)
	npc.tree_exiting.connect(_on_created_npc_tree_exiting.bind(npc))

	npc.global_position = _get_spawn_position(spawned_count)
	npc_created.emit(npc)
	print("[NPC] Civil criado: %s em %s por %s." % [
		npc.npc_name,
		str(npc.global_position),
		str(actor.name) if actor != null else "unknown",
	])
	return npc


func get_creation_status() -> String:
	_prune_invalid_npcs()
	if not creation_enabled:
		return "Casa Civil em construcao"
	return "%d/%d civis" % [spawned_count, max_spawned_npcs]


func _get_spawn_parent() -> Node:
	var configured_parent := get_node_or_null(spawn_parent_path)
	if configured_parent != null:
		return configured_parent

	var parent := get_parent()
	return parent if parent != null else self


func _get_spawn_position(index: int) -> Vector3:
	var safe_radius := maxf(spawn_radius, 0.5)
	var slots_per_ring := 6
	var zero_based_index := maxi(index - 1, 0)
	var ring := floori(float(zero_based_index) / float(slots_per_ring))
	var slot := zero_based_index % slots_per_ring
	var ring_radius := safe_radius + float(ring) * 1.5
	var angle_offset := (TAU / float(slots_per_ring)) * 0.5 * float(ring % 2)
	var angle := float(slot) * TAU / float(slots_per_ring) + angle_offset
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * ring_radius
	return global_position + offset


func _on_created_npc_tree_exiting(npc: NPCBase) -> void:
	_created_npcs.erase(npc)
	spawned_count = _created_npcs.size()


func _prune_invalid_npcs() -> void:
	for index in range(_created_npcs.size() - 1, -1, -1):
		if not is_instance_valid(_created_npcs[index]):
			_created_npcs.remove_at(index)
	spawned_count = _created_npcs.size()
