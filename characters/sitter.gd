extends PathFollow3D
class_name Sitter

@export()
var animation_player : AnimationPlayer

@export()
var action : String = "WalkCycle"

func _ready() -> void:
	animation_player.play(action)
	animation_player.get_animation(action).loop = true
