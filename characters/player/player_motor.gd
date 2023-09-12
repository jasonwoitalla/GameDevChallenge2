extends CharacterBody3D


@export var camera_path: NodePath

@onready var model: Node3D = $Model
@onready var coyote_timer: Timer = $CoyoteTimer


const SPEED: float = 10
const JUMP_VELOCITY: float = 14
const ROTATE_SPEED: float = 20
const MAX_VERTICAL_VEL: float = 50

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera: Camera3D
var jumping: bool = false
var can_jump: bool = true
var coyote: bool = false
var player_weight: float = 7.0

# Animation parameters
var linear_speed: float = 0
var is_grounded: bool = true


func _ready():
	camera = get_node(camera_path)


func _physics_process(delta):
	# Rotation while moving
	if camera and (velocity.x != 0 or velocity.y != 0):
		rotation.y = camera.rotation.y

	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif can_jump:
		velocity.y = -player_weight

	if is_on_ceiling():
		velocity.y = 0

	# Movement
	if direction:
		# Rotate the model to look at the direction
		var rotate_target: Basis = Basis.looking_at(Vector3(direction.x, 0, direction.z))
		rotate_target = Basis.from_euler(Vector3(model.global_rotation.x, rotate_target.get_euler().y, model.global_rotation.z))
		model.global_transform.basis = model.global_transform.basis.slerp(rotate_target, delta * ROTATE_SPEED)

		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Start Coyote Time
	if can_jump and not is_on_floor() and not coyote:
		coyote = true
		coyote_timer.start()
	
	# Reset Jump
	if not can_jump and is_on_floor() and not Input.is_action_pressed("jump"):
		can_jump = true
	
	# Jumping
	if Input.is_action_just_pressed("jump") and can_jump:
		jump()

	# Ceiling velocity cancel
	if is_on_ceiling() and velocity.y > 0:
		velocity.y = 0
	
	# Velocity Clamping
	velocity.y = clampf(velocity.y, -MAX_VERTICAL_VEL, MAX_VERTICAL_VEL)
	
	move_and_slide()

	# Set animation values
	linear_speed = Vector3(velocity.x, 0, velocity.z).length()
	is_grounded = is_on_floor()


func jump() -> void:
	can_jump = false
	velocity.y = JUMP_VELOCITY
	jumping = true


func _on_coyote_timer_timeout():
	can_jump = false
	coyote = false
