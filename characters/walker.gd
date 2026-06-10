extends PathFollow3D
class_name Walker

@export()
var animation_player : AnimationPlayer

@export()
var action : String = "WalkCycle"

@export()
var speed : float = 0.1

func _ready() -> void:
	animation_player.play(action)
	animation_player.get_animation(action).loop = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.progress_ratio += speed * delta
	if self.progress_ratio >= 1:
		self.progress_ratio = 0
