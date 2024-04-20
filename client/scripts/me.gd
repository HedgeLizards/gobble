extends CharacterBody2D

const speed := 10 * 16

func _physics_process(delta):
	move_and_collide(Input.get_vector("west", "east", "north", "south") * delta * speed)
