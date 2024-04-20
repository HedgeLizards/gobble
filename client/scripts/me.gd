extends CharacterBody2D

const speed := 10 * 16
var cooldown := 0.0

const Bullet = preload("res://scenes/bullet.tscn")

func _physics_process(delta):
	cooldown -= delta
	move_and_collide(Input.get_vector("west", "east", "north", "south") * delta * speed)
	
	%Gun.look_at(get_global_mouse_position())
	if Input.is_action_pressed("shoot") && cooldown < 0:
		shoot()

func shoot():
	cooldown = 0.5
	var bullet = Bullet.instantiate()
	bullet.position = %Muzzle.global_position
	bullet.rotation = %Muzzle.global_rotation
	$'../Projectiles'.add_child(bullet)
