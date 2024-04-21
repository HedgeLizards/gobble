extends CharacterBody2D

const weapons = [
	{
		"id": "Simple Hand Gun",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Gun.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"),
		"volume_db": 0.0,
		"cooldown": 0.5,
		"bullets": 1,
		"spread": PI / 180 * 5,
		"recoil_strength": 3.5,
	},
	{
		"id": "Automatic Rifle",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Assault_Rifle.png"),
		"stream": preload("res://sounds/SFX_AutomaticRifle_Fire.wav"),
		"volume_db": 0.0,
		"cooldown": 0.1,
		"bullets": 1,
		"spread": PI / 180 * 5,
		"recoil_strength": 3.5,
	},
	{
		"id": "Minigun",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Minigun.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"), # TO DO: Replace with weapon-specific sound
		"volume_db": 0.0,
		"cooldown": 0.025,
		"bullets": 1,
		"spread": PI / 180 * 10,
		"recoil_strength": 3.5,
	},
	{
		"id": "Sniper Rifle",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Sniper.png"),
		"stream": preload("res://sounds/SFX_SniperRifle_Fire.wav"),
		"volume_db": 0.0,
		"cooldown": 5.0,
		"bullets": 1,
		"spread": 0.0,
		"recoil_strength": 7.5,
	},
	{
		"id": "Shotgun",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Shotgun.png"),
		"stream": preload("res://sounds/SFX_Shotgun_Fire.wav"),
		"volume_db": 0.0,
		"cooldown": 1.5,
		"bullets": 5,
		"spread": PI / 180 * 20,
		"recoil_strength": 5.0,
	},
	{
		"id": "Grenade Launcher",
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Granande_Launcher.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"), # TO DO: Replace with weapon-specific sound
		"volume_db": 0.0,
		"cooldown": 5.0,
		"bullets": 1,
		"spread": 0.0,
		"recoil_strength": 15.0,
	},
	{
		"id": "Bow",
		"texture": preload("res://assets/Knights/knight_bow.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"), # TO DO: Replace with weapon-specific sound
		"volume_db": -80.0,
	},
	{
		"id": "Sword",
		"texture": preload("res://assets/Knights/Knight_sword.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"), # TO DO: Replace with weapon-specific sound
		"volume_db": -80.0,
	},
]
var weapon_index:
	set(value):
		weapon_index = value
		weapon = weapons[weapon_index]
		
		$Weapon/Sprite2D.texture = weapon.texture
		
		$Shoot.stream.set_stream(0, weapon.stream)
		$Shoot.volume_db = weapon.volume_db
var weapon

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
				weapon_index = (-1 if weapon_index == (weapons.size() - 2) - 1 else weapon_index) + 1
			MOUSE_BUTTON_WHEEL_DOWN:
				weapon_index = ((weapons.size() - 2) if weapon_index == 0 else weapon_index) - 1
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
		shoot()

func shoot():
	$Shoot.play()
	cooldown = weapon.cooldown
	var direction = %Muzzle.global_rotation + randf_range(-weapon.spread / 2.0, weapon.spread / 2.0)
	for i in weapon.bullets:
		var bullet = Bullet.instantiate()
		bullet.id = "@bullet_"+WebSocket.local_player_name + str(randi())
		bullet.position = %Muzzle.global_position
		bullet.rotation = direction + (i - weapon.bullets / 2.0 + 0.5) * weapon.spread / 4.0
		$'../Projectiles'.add_child(bullet)
		WebSocket.send({
			"type": "createProjectile",
			"id": bullet.id,
			"playerId": WebSocket.local_player_name,
			"pos": [bullet.position.x / 16, bullet.position.y / 16],
			"rotation": bullet.rotation,
			"speed": bullet.speed / 16,
			"distance": bullet.distance / 16,
			"isEnemy": false,
			"kind": weapons[weapon_index].get("bullet", "bullet"),
		})
	$Camera2D.recoil(-direction, weapon.recoil_strength)


func is_me():
	return true

