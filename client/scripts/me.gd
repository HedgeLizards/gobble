extends CharacterBody2D



const player_weapons: Array[String] = ["Handgun", "AssaultRifle", "Minigun", "Sniper", "Shotgun", "GrenadeLauncher"]

var weapon_index := -1:
	set(value):
		if value == weapon_index:
			return
		
		if weapon_id() == "Minigun" and Input.is_action_pressed("shoot") and $ShootInteractive.playing:
			$ShootInteractive.get_stream_playback().switch_to_clip_by_name("Minigun Shutdown")
		
		weapon_index = value
		weapon = Weapons.weapons[weapon_id()]
		
		$Weapon/Sprite2D.texture = weapon.texture
		
		if weapon.stream is AudioStreamInteractive:
			$ShootInteractive.stream = weapon.stream
			$ShootInteractive.volume_db = weapon.volume_db
		elif weapon.stream != null:
			$Shoot.stream.set_stream(0, weapon.stream)
			$Shoot.volume_db = weapon.volume_db
var weapon: Weapons.Weapon
var playing_interactive = false

const speed := 10.0 * Globals.SCALE
var cooldown := 0.0
const maxhealth := 100.0
var health := maxhealth:
	set(value):
		if value == health:
			return
		health = value
		%HealthBar.ratio = clamp(health / maxhealth, 0, 1)

var alive: bool = false:
	set(value):
		alive = value
		$Sprite2D.visible = value
		%HealthBar.visible = value
		$Weapon.visible = value
		$GhostSprite.visible = !value


const LocalProjectile = preload("res://scenes/local_projectile.tscn")

func _ready():
	weapon_index = 0
	alive = false
	
	$Label.text = WebSocket.local_player_name

func _on_label_resized():
	$Label.position.x = (-$Label.size.x / 2.0 + 0.5) * $Label.scale.x
	%HealthBar.resize_to_fit($Label)

func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					weapon_index = posmod(weapon_index + 1, player_weapons.size())
				MOUSE_BUTTON_WHEEL_DOWN:
					weapon_index = posmod(weapon_index - 1, player_weapons.size())
	elif event is InputEventKey:
		if event.pressed and event.keycode >= KEY_1 and event.keycode <= KEY_6 and not event.echo:
			weapon_index = event.keycode - KEY_1
	
	if playing_interactive and (Input.is_action_just_released("shoot") or weapon_id() != "Minigun"):
		$ShootInteractive.get_stream_playback().switch_to_clip_by_name("Minigun Shutdown")
		playing_interactive = false

func _process(delta) -> void:
	%Weapon.look_at(get_global_mouse_position())
	%Weapon.rotation = fposmod(%Weapon.rotation, TAU)
	%Weapon.scale.y = -1 if %Weapon.rotation > 0.5 * PI and %Weapon.rotation < 1.5 * PI else 1

func _physics_process(delta) -> void:
	var previous_position = position
	move_and_collide(Input.get_vector("west", "east", "north", "south") * delta * speed)
	$Sprite2D.animate(position, previous_position, delta)
	
	cooldown = max(cooldown - delta, 0.0)
	if Input.is_action_pressed("shoot") and cooldown == 0.0 and is_alive():
		shoot()
	
	if alive:
		WebSocket.send({
			"type": "updatePlayer",
			"pos": [position.x / Globals.SCALE, position.y / Globals.SCALE],
			"aim": %Weapon.rotation,
			"activity": { "type": "shooting" if Input.is_action_pressed("shoot") else "idle" },
			"weapon": weapon_id(),
		})

func shoot() -> void:
	if weapon_id() == "Minigun":
		if !playing_interactive:
			$ShootInteractive.play()
			playing_interactive = true
	elif weapon.stream != null:
		$Shoot.play()
	cooldown = weapon.cooldown
	var direction = %Muzzle.global_rotation + randf_range(-weapon.spread / 2.0, weapon.spread / 2.0)
	var projectiles = []
	for i in weapon.bullets:
		var bullet = LocalProjectile.instantiate()
		bullet.id = "B:"+WebSocket.local_player_id + ";" + str(randi())
		bullet.position = %Muzzle.global_position
		bullet.rotation = direction + (i - weapon.bullets / 2.0 + 0.5) * weapon.spread / 4.0
		$'../Projectiles'.add_child(bullet)
		projectiles.push_back({
			"id": bullet.id,
			"pos": [bullet.position.x / Globals.SCALE, bullet.position.y / Globals.SCALE],
			"rotation": bullet.rotation,
			"speed": bullet.speed / Globals.SCALE,
			"distance": bullet.distance / Globals.SCALE,
			"kind": weapon.bullet,
			"damage": bullet.damage,
		})
	WebSocket.send({
		"type": "createProjectiles",
		"creatorId": WebSocket.local_player_id,
		"isEnemy": false,
		"projectiles": projectiles,
	})
	$Camera2D.recoil(-direction, weapon.recoil_strength)

func weapon_id() -> String:
	return player_weapons[weapon_index]

func is_me() -> bool:
	return true

func is_alive() -> bool:
	return alive

