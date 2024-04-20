extends Sprite2D

var speed: float


func _physics_process(delta):
	move_local_x(speed * delta)
