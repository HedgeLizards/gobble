extends CharacterBody2D

const speed := 10 * 16
var cooldown := 0.0

const Bullet = preload("res://scenes/bullet.tscn")

func _ready():
	$Label.text = WebSocket.local_player_name

func _on_label_resized():
	$Label.position.x = (-$Label.size.x / 2.0 + 0.5) * $Label.scale.x

func _physics_process(delta):
	cooldown -= delta
	var previous_position = position
	move_and_collide(Input.get_vector("west", "east", "north", "south") * delta * speed)
	$Sprite2D.animate(position, previous_position, delta)
	
	%Weapon.look_at(get_global_mouse_position())
	%Weapon.rotation = fposmod(%Weapon.rotation, TAU)
	%Weapon.scale.y = -1 if %Weapon.rotation > 0.5 * PI && %Weapon.rotation < 1.5 * PI else 1
	if Input.is_action_pressed("shoot") && cooldown < 0:
		$Shoot.play()
		shoot()

func shoot():
	cooldown = 0.5
	var bullet = Bullet.instantiate()
	bullet.id = "@bullet_"+WebSocket.local_player_name + str(randi())
	bullet.position = %Muzzle.global_position
	bullet.rotation = %Muzzle.global_rotation
	$'../Projectiles'.add_child(bullet)
	WebSocket.send({
		"type": "createProjectile",
		"id": bullet.id,
		"playerId": WebSocket.local_player_name,
		"pos": [bullet.position.x / 16, bullet.position.y / 16],
		"rotation": bullet.rotation,
		"speed": bullet.speed
	})
