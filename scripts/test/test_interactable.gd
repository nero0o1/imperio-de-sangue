extends StaticBody3D

@export var display_name := "Test interactable"

var interaction_count := 0


func interact(actor: Node) -> void:
	interaction_count += 1

	var actor_name := "unknown actor"
	if actor != null:
		actor_name = str(actor.name)

	print("interact(actor) called on %s by %s. Count: %d" % [display_name, actor_name, interaction_count])
