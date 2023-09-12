extends Control

@export var main_camera: NodePath

@onready var greyscale: ColorRect = $Greyscale
@onready var viewport: SubViewportContainer = $SubViewportContainer
@onready var recall_view: Camera3D = $SubViewportContainer/SubViewport/RecallView
@onready var recall_progress: TextureProgressBar = $RecallProgress
@onready var state_label: RichTextLabel = $RichTextLabel

signal cancel_recall

var camera: Camera3D
var recalling_object: Recallable
var progress_tween: Tween

var recalling: bool = false:
	get:
		return recalling
	set(value):
		recalling = value
		if not value:
			set_state_label("Neutral")
			disable_greyscale()
		else:
			set_state_label("Recalling")
			

var recall_select: bool = false:
	get:
		return recall_select
	set(value):
		var recallable_nodes = get_tree().get_nodes_in_group("recallable")
		if value:
			if recalling:
				return
			set_state_label("Recall Select")
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			enable_greyscale()
			recall_view.transform = camera.transform
			for recallable_node in recallable_nodes:
				recallable_node.start_recalling.connect(_on_recallable_start_recalling)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			for recallable_node in recallable_nodes:
				recallable_node.start_recalling.disconnect(_on_recallable_start_recalling)
			if not recalling:
				set_state_label("Neutral")
				disable_greyscale()
		
		recall_select = value
		get_tree().paused = recall_select

func _ready():
	camera = get_node(main_camera)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("recall"):
		recall_select = !recall_select
		if recalling:
			cancel_recall.emit()

	if recalling:
		recall_view.transform = camera.transform
		display_recall_progress()


func _on_recallable_start_recalling(object: Recallable, length: int, timestep: float):
	recalling = true
	recall_select = false
	object.finished_recalling.connect(_on_recallable_finished_recalling)
	cancel_recall.connect(object._on_recall_manager_cancel_recall)
	recalling_object = object
	# UI
	var time = length * timestep
	recall_progress.max_value = time
	recall_progress.value = time
	if progress_tween:
		progress_tween.kill()

	progress_tween = recall_progress.create_tween()
	progress_tween.tween_property(recall_progress, "value", 0, time)
	progress_tween.tween_callback(func(): recall_progress.hide())
	

func _on_recallable_finished_recalling(object: Recallable):
	object.finished_recalling.disconnect(_on_recallable_finished_recalling)
	cancel_recall.disconnect(object._on_recall_manager_cancel_recall)
	recalling = false
	recall_progress.hide()


func enable_greyscale():
	greyscale.visible = true
	viewport.visible = true


func disable_greyscale():
	greyscale.visible = false
	viewport.visible = false


func display_recall_progress():
	recall_progress.visible = not get_viewport().get_camera_3d().is_position_behind(recalling_object.global_transform.origin)
	recall_progress.position = get_viewport().get_camera_3d().unproject_position(recalling_object.global_transform.origin)


func set_state_label(state: String):
	state_label.text = "State: {0}".format({"0": state})
