extends StaticBody3D

@export var wood_per_interaction: int = 5
@export var max_uses: int = 3
@export var destroy_when_depleted: bool = true

var remaining_uses: int = 0


func _ready() -> void:
	remaining_uses = maxi(max_uses, 0)

	if wood_per_interaction <= 0:
		push_warning("[WoodNode] wood_per_interaction deve ser maior que zero.")

	if max_uses <= 0:
		push_warning("[WoodNode] max_uses deve ser maior que zero para permitir coleta.")


func interact(actor: Node) -> void:
	if remaining_uses <= 0:
		print("[WoodNode] Recurso esgotado.")
		_handle_depleted()
		return

	if wood_per_interaction <= 0:
		push_warning("[WoodNode] Coleta ignorada. wood_per_interaction invalido: %d" % wood_per_interaction)
		return

	var resource_manager := get_node_or_null("/root/ResourceManager")
	if resource_manager == null or not resource_manager.has_method("add_wood"):
		push_warning("[WoodNode] ResourceManager nao encontrado. Madeira nao coletada.")
		return

	resource_manager.call("add_wood", wood_per_interaction)
	remaining_uses -= 1

	var actor_name := "unknown actor"
	if actor != null:
		actor_name = str(actor.name)

	print("[WoodNode] Coletado por %s. +%d madeira. Usos restantes: %d" % [actor_name, wood_per_interaction, remaining_uses])

	if remaining_uses <= 0:
		_handle_depleted()


func _handle_depleted() -> void:
	if destroy_when_depleted and not is_queued_for_deletion():
		print("[WoodNode] Recurso esgotado. Removendo no.")
		queue_free()
