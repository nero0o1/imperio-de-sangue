extends CharacterBody3D

signal player_died

@export var walk_speed       := 5.0
@export var sprint_speed     := 8.0
@export var mouse_sensitivity := 0.0025
@export var max_health       := 100
# Velocidade vertical aplicada no salto. Ajuste no Inspector conforme necessario.
@export var jump_velocity    := 6.5

# Controle de chao
@export var ground_acceleration := 20.0  # quao rapido o jogador atinge a velocidade alvo no chao
@export var ground_deceleration := 18.0  # quao rapido desacelera ao soltar as teclas no chao

# Controle aereo (valores baixos = sensacao de peso/inertia no ar)
@export var air_control      := 0.12   # fator 0..1 aplicado sobre ground_acceleration no ar
@export var air_deceleration := 4.0   # desaceleracao horizontal no ar ao nao pressionar teclas

@onready var camera: Camera3D = $Camera3D
@onready var interaction_raycast := $Camera3D/InteractionRayCast

var health := max_health
var _pitch := 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Impede que o clique de recaptura do mouse seja interpretado como ataque.
var _mouse_just_recaptured := false


func _ready() -> void:
	health = max_health
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if _is_ui_blocking_gameplay():
		return

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-85.0), deg_to_rad(85.0))
		camera.rotation.x = _pitch
		return

	# ESC libera o mouse.
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_viewport().set_input_as_handled()
		return

	# Clique recaptura o mouse, mas nao deve ser tratado como ataque.
	if event is InputEventMouseButton and event.pressed \
			and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_mouse_just_recaptured = true
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if _is_ui_blocking_gameplay():
		_apply_movement_blocked(delta)
		return

	_apply_movement(delta)

	if Input.is_action_just_pressed("jump"):
		jump()

	if Input.is_action_just_pressed("interact"):
		if not _try_consume_scene_interact():
			try_interact()

	# Ignora o ataque no frame em que o mouse foi recapturado.
	if Input.is_action_just_pressed("attack"):
		if _mouse_just_recaptured:
			_mouse_just_recaptured = false
		else:
			attack()
	else:
		_mouse_just_recaptured = false


func _apply_movement(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if is_on_floor():
		# --- Movimento no chao ---
		# Sprint so e permitido quando o jogador esta no chao.
		var target_speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed

		if direction != Vector3.ZERO:
			# Interpola em direcao a velocidade alvo com aceleracao de chao.
			var target_h := direction * target_speed
			velocity.x = move_toward(velocity.x, target_h.x, ground_acceleration * delta)
			velocity.z = move_toward(velocity.z, target_h.z, ground_acceleration * delta)
		else:
			# Sem input: desacelera rapidamente no chao.
			velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)
			velocity.z = move_toward(velocity.z, 0.0, ground_deceleration * delta)
	else:
		# --- Movimento no ar ---
		# Aplica gravidade continuamente; velocity.y e zerada pelo chao via move_and_slide.
		velocity.y -= _gravity * delta

		if direction != Vector3.ZERO:
			# Influencia aerea limitada: usa a velocidade horizontal atual como base
			# e aplica apenas uma fracao da aceleracao de chao (air_control).
			# Sprint nao e aplicado no ar.
			var current_h_speed := Vector2(velocity.x, velocity.z).length()
			var air_target_speed := minf(current_h_speed, walk_speed)  # nunca ultrapassa velocidade de caminhada no ar
			var target_h := direction * air_target_speed
			var accel := ground_acceleration * air_control
			velocity.x = move_toward(velocity.x, target_h.x, accel * delta)
			velocity.z = move_toward(velocity.z, target_h.z, accel * delta)
		else:
			# Sem input no ar: desaceleracao suave preservando inertia do salto.
			velocity.x = move_toward(velocity.x, 0.0, air_deceleration * delta)
			velocity.z = move_toward(velocity.z, 0.0, air_deceleration * delta)

	move_and_slide()


func _apply_movement_blocked(delta: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, ground_deceleration * delta)
	else:
		velocity.y -= _gravity * delta
		velocity.x = move_toward(velocity.x, 0.0, air_deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, air_deceleration * delta)
	
	move_and_slide()


func _is_ui_blocking_gameplay() -> bool:
	var blockers = get_tree().get_nodes_in_group("gameplay_input_blocker")
	for blocker in blockers:
		if blocker.has_method("is_inventory_ui_open") and blocker.is_inventory_ui_open():
			return true
	return false


func try_interact() -> bool:
	if interaction_raycast != null and interaction_raycast.has_method("try_interact"):
		return interaction_raycast.try_interact(self)

	return false


func _try_consume_scene_interact() -> bool:
	var current_scene := get_tree().current_scene
	if current_scene != null and current_scene.has_method("try_consume_player_interact"):
		return bool(current_scene.call("try_consume_player_interact", self))

	return false


func get_inventory() -> PlayerInventory:
	var direct := get_node_or_null("PlayerInventory")
	if direct is PlayerInventory:
		return direct

	for child in get_children():
		if child is PlayerInventory:
			return child

	return null


# Pulo: so executa quando o Player esta no chao. Sem pulo duplo.
func jump() -> void:
	if not is_on_floor():
		return
	print_debug("jump() chamado... velocity.y = %.2f" % jump_velocity)
	velocity.y = jump_velocity


# Wave 1 stub: sem dano real. Combate fica para uma wave futura.
func attack() -> void:
	print_debug("attack() chamado: stub Wave 1. Sem dano real. Combate reservado para wave futura.")


func take_damage(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return

	health = maxi(health - amount, 0)

	if health == 0:
		die()


func die() -> void:
	player_died.emit()
