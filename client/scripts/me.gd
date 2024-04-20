extends CharacterBody2D

const speed := 10 * 16
var cooldown := 0.0

const Bullet = preload("res://scenes/bullet.tscn")

func _physics_process(delta):
	cooldown -= delta
	var previous_position = position
	move_and_collide(Input.get_vector("west", "east", "north", "south") * delta * speed)
	$Sprite2D.animate(position, previous_position, delta)
	
	%Gun.look_at(get_global_mouse_position())
	%Gun.rotation = fposmod(%Gun.rotation, TAU)
	%Gun.scale.y = -1 if %Gun.rotation > 0.5 * PI && %Gun.rotation < 1.5 * PI else 1
	if Input.is_action_pressed("shoot") && cooldown < 0:
		$Shoot.play()
		shoot()

func shoot():
	cooldown = 0.5
	var bullet = Bullet.instantiate()
	bullet.position = %Muzzle.global_position
	bullet.rotation = %Muzzle.global_rotation
	$'../Projectiles'.add_child(bullet)
