extends CharacterBody2D



const player_weapons: Array[String] = ["Handgun", "AssaultRifle", "Minigun", "Sniper", "Shotgun", "GrenadeLauncher"]

var weapon_index := -1:
	set(value):
		if weapon_index == value:
			return
		weapon_index = value
		weapon = Weapons.weapons[player_weapons[weapon_index]]
		
		$Weapon/Sprite2D.texture = weapon.texture
		
		if weapon.stream is AudioStreamInteractive:
			$ShootInteractive.stream = weapon.stream
			$ShootInteractive.volume_db = weapon.volume_db
		elif weapon.stream != null:
			$Shoot.stream.set_stream(0, weapon.stream)
			$Shoot.volume_db = weapon.volume_db
var weapon: Weapons.Weapon

const speed := 10.0 * Globals.SCALE
var cooldown := 0.0
const maxhealth := 100.0
var health := maxhealth:
	set(value):
		health = value
		var ratio := clamp(health / maxhealth, 0, 1)
		$HealthBar/Healthy.size.x = $HealthBar.size.x * ratio

const LocalProjectile = preload("res://scenes/local_projectile.tscn")

func _ready():
	weapon_index = 0
	
	$Label.text = WebSocket.local_player_name

func _on_label_resized():
	$Label.position.x = (-$Label.size.x / 2.0 + 0.5) * $Label.scale.x

func _unhandled_input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				weapon_index = posmod(weapon_index + 1, player_weapons.size())
			MOUSE_BUTTON_WHEEL_DOWN:
				weapon_index = posmod(weapon_index - 1, player_weapons.size())
	elif event is InputEventKey:
		if event.keycode >= KEY_1 and event.keycode <= KEY_6 and event.pressed and not event.echo:
			weapon_index = event.keycode - KEY_1

func _physics_process(delta) -> void:
	cooldown -= delta
	var previous_position = position
	move_and_collide(Input.get_vector("west", "east", "north", "south") * delta * speed)
	$Sprite2D.animate(position, previous_position, delta)
	
	%Weapon.look_at(get_global_mouse_position())
	%Weapon.rotation = fposmod(%Weapon.rotation, TAU)
	%Weapon.scale.y = -1 if %Weapon.rotation > 0.5 * PI && %Weapon.rotation < 1.5 * PI else 1
	
	if weapon_id() == "Minigun":
		if Input.is_action_just_pressed("shoot"):
			$ShootInteractive.play()
		elif Input.is_action_just_released("shoot"):
			$ShootInteractive.get_stream_playback().switch_to_clip_by_name("Minigun Shutdown")
	if Input.is_action_pressed("shoot") && cooldown < 0:
		shoot()

func shoot() -> void:
	if not weapon.stream is AudioStreamInteractive and weapon.stream != null:
		$Shoot.play()
	cooldown = weapon.cooldown
	var direction = %Muzzle.global_rotation + randf_range(-weapon.spread / 2.0, weapon.spread / 2.0)
	for i in weapon.bullets:
		var bullet = LocalProjectile.instantiate()
		bullet.id = "@bullet_"+WebSocket.local_player_name + str(randi())
		bullet.position = %Muzzle.global_position
		bullet.rotation = direction + (i - weapon.bullets / 2.0 + 0.5) * weapon.spread / 4.0
		$'../Projectiles'.add_child(bullet)
		WebSocket.send({
			"type": "createProjectile",
			"id": bullet.id,
			"playerId": WebSocket.local_player_name,
			"pos": [bullet.position.x / Globals.SCALE, bullet.position.y / Globals.SCALE],
			"rotation": bullet.rotation,
			"speed": bullet.speed / Globals.SCALE,
			"distance": bullet.distance / Globals.SCALE,
			"isEnemy": false,
			"kind": weapon.bullet,
		})
	$Camera2D.recoil(-direction, weapon.recoil_strength)

func weapon_id() -> String:
	return player_weapons[weapon_index]

func hit(damage: float) -> void:
	health -= damage

func is_me() -> bool:
	return true

