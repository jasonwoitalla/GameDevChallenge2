extends RigidBody3D


func _on_motion_trigger_body_entered(_body:Node3D):
	set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, false)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Y, false)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, false)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_X, false)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_Y, false)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_Z, false)
