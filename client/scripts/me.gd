extends CharacterBody2D

const weapons = [
	{
		"id": "Simple Hand Gun",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Gun.png")
	},
	{
		"id": "Automatic Rifle",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Assault_Rifle.png")
	},
	{
		"id": "Minigun",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Minigun.png")
	},
	{
		"id": "Sniper Rifle",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Sniper.png")
	},
	{
		"id": "Shotgun",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Shotgun.png")
	},
	{
		"id": "Grenade Launcher",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Assault_Rifle.png")
	},
	{
		"id": "Bow",
		"texture": preload("res://assets/Knights/knight_bow.png")
	},
	{
		"id": "Sword",
		"texture": preload("res://assets/Knights/Knight_sword.png")
	},
]

var weapon_index:
	set(value):
		weapon_index = value
		
		$Weapon/Sprite2D.texture = weapons[weapon_index].texture

const speed := 10 * 16
var cooldown := 0.0

const Bullet = preload("res://scenes/bullet.tscn")

func _ready():
	weapon_index = 0
	
	$Label.text = WebSocket.local_player_name

func _on_label_resized():
	$Label.position.x = (-$Label.size.x / 2.0 + 0.5) * $Label.scale.x

func _unhandled_input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				weapon_index = (-1 if weapon_index == weapons.size() - 1 else weapon_index) + 1
			MOUSE_BUTTON_WHEEL_DOWN:
				weapon_index = (weapons.size() if weapon_index == 0 else weapon_index) - 1
	elif event is InputEventKey:
		if event.keycode >= KEY_1 and event.keycode <= KEY_6 and event.pressed and not event.echo:
			weapon_index = event.keycode - KEY_1

func _physics_process(delta):
	cooldown -= delta
	var previous_position = position
	move_and_collide(Input.get_vector("west", "east", "north", "south") * delta * speed)
	$Sprite2D.animate(position, previous_position, delta)
	
	%Weapon.look_at(get_global_mouse_position())
	%Weapon.rotation = fposmod(%Weapon.rotation, TAU)
	%Weapon.scale.y = -1 if %Weapon.rotation > 0.5 * PI && %Weapon.rotation < 1.5 * PI else 1
	if Input.is_action_pressed("shoot") && cooldown < 0:
		# TO DO: Add weapon selection logic; sound needs to match the weapon.
		$Shoot.play()
		shoot()

func shoot():
	cooldown = 0.5
	var bullet = Bullet.instantiate()
	bullet.id = "@bullet_"+WebSocket.local_player_name + str(randi())
	bullet.position = %Muzzle.global_position
	bullet.rotation = %Muzzle.global_rotation
	$Camera2D.recoil(-%Muzzle.global_rotation)
	$'../Projectiles'.add_child(bullet)
	WebSocket.send({
		"type": "createProjectile",
		"id": bullet.id,
		"playerId": WebSocket.local_player_name,
		"pos": [bullet.position.x / 16, bullet.position.y / 16],
		"rotation": bullet.rotation,
		"speed": bullet.speed / 16,
		"distance": bullet.distance / 16,
		"isEnemy": false
	})

func is_me():
	return true

