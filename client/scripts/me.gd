extends CharacterBody2D

const speed := 200.0

func _physics_process(delta):
	move_and_collide(Input.get_vector("west", "east", "north", "south") * delta * speed)
