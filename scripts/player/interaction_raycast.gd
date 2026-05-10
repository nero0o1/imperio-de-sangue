extends RayCast3D

@export var debug_messages := true


func try_interact(actor: Node) -> bool:
	clear_exceptions()

	var collision_actor := actor as CollisionObject3D
	if collision_actor != null:
		add_exception(collision_actor)

	force_raycast_update()

	if not is_colliding():
		if debug_messages:
			print_debug("[Interação] Nenhum alvo encontrado pelo InteractionRayCast.")
		return false

	var target := get_collider()

	if target != null and target.has_method("interact"):
		if debug_messages:
			print("[Interação] Jogador interagindo com %s." % str(target.name))
		target.interact(actor)
		return true

	if debug_messages:
		var target_name := "alvo desconhecido"
		if target != null:
			target_name = str(target.name)
		print_debug("[Interação] Alvo não implementa interact(actor): %s" % target_name)

	return false
