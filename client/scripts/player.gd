extends CharacterBody2D


var playername: String
var speed = 200
# Called when the node enters the scene tree for the first time.
func _ready():
	playername = "player" + str(randi()) # todo: random name gen or choosing


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_collide(Input.get_vector("west", "east", "north", "south") * delta * speed)
