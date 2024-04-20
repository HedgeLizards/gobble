extends CharacterBody2D


var speed = 2
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_and_collide(Input.get_vector("west", "east", "north", "south") * speed)
