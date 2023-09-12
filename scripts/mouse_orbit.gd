extends Camera3D


@export var target: NodePath
@export var distance: float = 15.0
@export var max_distance: float = 15.0
@export var min_distance: float = 2.0
@export var x_speed: float = 250.0
@export var y_speed: float = 120.0
@export var y_min_limit: float = -40
@export var y_max_limit: float = 55
@export var acceleration: float = 0.5

var mouse_delta: Vector2 = Vector2.ZERO
var stop_camera: bool = false
var x: float = 0.0
var y: float = 0.0
var zoom_speed: float = 20

var target_node: Node3D
var zoom_target_node: Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	x = rotation.y
	y = rotation.x
	
	target_node = get_node(target)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var quat : Quaternion = Quaternion.IDENTITY
	
	if not stop_camera:
		x -= mouse_delta.x * x_speed * delta
		y -= mouse_delta.y * y_speed * delta
		
		y = clamp_angle(y, y_min_limit, y_max_limit)
		
		distance += Input.get_axis("camera_zoom_in", "camera_zoom_out") * zoom_speed
		distance = clampf(distance, min_distance, max_distance)
		
		rotation = Vector3(deg_to_rad(y), deg_to_rad(x), 0)
		quat = Quaternion.from_euler(rotation)
		position = quat * Vector3.BACK * distance + get_target().global_position
	
	mouse_delta = Vector2.ZERO


func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = mouse_delta.move_toward(event.relative.normalized(), acceleration)
	elif event is InputEventKey: # Free mouse on escape
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# elif event is InputEventMouseButton: # Caputre mosue on click
	# 	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
	# 		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func get_target() -> Node3D:
	return target_node


func clamp_angle(angle : float, min_angle : float, max_angle : float) -> float:
	if angle < -360:
		angle += 360
	if angle > 360:
		angle -= 360
	return clampf(angle, min_angle, max_angle)
