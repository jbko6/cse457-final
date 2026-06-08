extends Camera3D

@export var target : Node3D
@export var speed := 3

func _process(delta: float) -> void:
	# Slerp rotation
	var target_quat = Quaternion(target.global_transform.basis)
	var current_quat = Quaternion(transform.basis)
	transform.basis = Basis(current_quat.slerp(target_quat, delta*speed))

	# Lerp position
	position = lerp(position, target.global_position, delta * speed*(1+Global.player.speed*0.1))
