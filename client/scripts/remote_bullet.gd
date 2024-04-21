extends Sprite2D

var speed: float
var distance: float

func _physics_process(delta):
	distance -= speed * delta
	if distance < 0:
		queue_free()
	move_local_x(speed * delta * 16)
