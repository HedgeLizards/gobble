extends CharacterBody2D



var weapon_id: String:
	set(value):
		if value == weapon_id:
			return
		
		if weapon_id == "Minigun" and Input.is_action_pressed("shoot") and $ShootInteractive.playing:
			$ShootInteractive.get_stream_playback().switch_to_clip_by_name("Minigun Shutdown")
		
		weapon_id = value
		weapon = Weapons.weapons[weapon_id]
		
		$Weapon/Sprite2D.texture = weapon.texture
		
		if weapon.stream is AudioStreamInteractive:
			$ShootInteractive.stream = weapon.stream
			$ShootInteractive.volume_db = weapon.volume_db
		elif weapon.stream != null:
			$Shoot.stream.set_stream(0, weapon.stream)
			$Shoot.volume_db = weapon.volume_db
		
		$Camera2D.zoom_factor = 1.5 if weapon_id == "Sniper" else 1.0
var weapon: Weapons.Weapon

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
		$CollisionShape2D.disabled = !value
		%HealthBar.visible = value
		$Weapon.visible = value
		$GhostSprite.visible = !value
		set_process_unhandled_key_input(value)
		if not value:
			weapon_id = "Handgun"
			var UI = $"../UI"
			if UI.building:
				UI.building = false
				was_placing_building = false
var was_placing_building = false

const LocalProjectile = preload("res://scenes/local_projectile.tscn")

func _ready():
	weapon_id = "Handgun"
	alive = false
	
	$Label.text = WebSocket.local_player_name

func _on_label_resized():
	$Label.position.x = (-$Label.size.x / 2.0 + 0.5) * $Label.scale.x
	%HealthBar.resize_to_fit($Label)

func _unhandled_key_input(event) -> void:
	if event.keycode == KEY_B and event.pressed and not event.echo:
		var UI = $"../UI"
		
		UI.building = !UI.building
		
		if not UI.building:
			was_placing_building = false

func _process(delta) -> void:
	%Weapon.look_at(get_global_mouse_position())
	%Weapon.rotation = fposmod(%Weapon.rotation, TAU)
	%Weapon.scale.y = -1 if %Weapon.rotation > 0.5 * PI and %Weapon.rotation < 1.5 * PI else 1

func _physics_process(delta) -> void:
	var previous_position = position
	velocity = Input.get_vector("west", "east", "north", "south") * speed
	move_and_slide()
	$Sprite2D.animate(position, previous_position, delta)
	if !is_equal_approx(position.x, previous_position.x):
		$GhostSprite.flip_h = (position.x < previous_position.x)
	
	cooldown = max(cooldown - delta, 0.0)
	if was_placing_building:
		if Input.is_action_just_released("shoot"):
			was_placing_building = false
	elif $"../UI".placing == null:
		if weapon_id == "Minigun":
			if Input.is_action_just_pressed("shoot") or (Input.is_action_pressed("shoot") and not $ShootInteractive.playing):
				if cooldown == 0.0:
					$ShootInteractive.play()
			elif Input.is_action_just_released("shoot"):
				if $ShootInteractive.playing:
					$ShootInteractive.get_stream_playback().switch_to_clip_by_name("Minigun Shutdown")
		elif weapon.stream != null:
			if Input.is_action_pressed("shoot") and cooldown == 0.0 and is_alive():
				$Shoot.play()
		if Input.is_action_pressed("shoot") and cooldown == 0.0 and is_alive():
			shoot()
	else:
		was_placing_building = true
	
	if alive:
		WebSocket.send({
			"type": "updatePlayer",
			"pos": [position.x / Globals.SCALE, position.y / Globals.SCALE],
			"aim": %Weapon.rotation,
			"activity": { "type": "shooting" if Input.is_action_pressed("shoot") and not was_placing_building else "idle" },
			"weapon": weapon_id,
		})

func shoot() -> void:
	cooldown = weapon.cooldown
	var direction = %Muzzle.global_rotation + randf_range(-weapon.spread / 2.0, weapon.spread / 2.0)
	var projectiles = []
	for i in weapon.bullets:
		var bullet = LocalProjectile.instantiate()
		bullet.id = "B:"+WebSocket.local_player_id + ";" + str(randi())
		bullet.position = %Muzzle.global_position
		bullet.rotation = direction + (i - weapon.bullets / 2.0 + 0.5) * weapon.spread / 4.0
		bullet.weapon_id = weapon_id
		$"../Projectiles".add_child(bullet)
		projectiles.push_back({
			"id": bullet.id,
			"pos": [bullet.position.x / Globals.SCALE, bullet.position.y / Globals.SCALE],
			"rotation": bullet.rotation,
		})
	WebSocket.send({
		"type": "createProjectiles",
		"creatorId": WebSocket.local_player_id,
		"isEnemy": false,
		"weapon": weapon_id,
		"projectiles": projectiles,
	})
	$Camera2D.recoil(-direction, weapon.recoil_strength)

func is_alive() -> bool:
	return alive

