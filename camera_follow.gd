extends Camera3D

@export var target : Node3D
@export var dead_target : Node3D
@export var speed := 3

var target_quat

func _process(delta: float) -> void:
	if Global.player.alive:
		# Slerp rotation
		target_quat = Quaternion(target.global_transform.basis)
		var current_quat = Quaternion(transform.basis)
		transform.basis = Basis(current_quat.slerp(target_quat, delta*speed))
		# Lerp position
		position = lerp(position, target.global_position, delta * speed*(1+Global.player.speed*0.1))
	else:
		rotation = lerp(
			rotation,
			transform.looking_at(dead_target.global_position).basis.get_euler(),
			delta*10)
