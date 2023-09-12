extends CharacterBody3D


@export var speed: float = 10.0
@export var gravity_enabled: bool = true

@onready var destruction_timer: Timer = $DestructionTimer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	var direction: Vector3 = (transform.basis * Vector3(0, 0, 1)).normalized()
	
	if not get_tree().paused:
		velocity = direction * speed

		if gravity_enabled and not is_on_floor():
			velocity.y -= gravity * delta
	else:
		velocity = Vector3.ZERO
		if not destruction_timer.is_stopped():
			destruction_timer.stop()

	move_and_slide()


func _on_destruction_timer_timeout():
	queue_free()
