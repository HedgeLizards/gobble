extends Area2D

var positions = []
var enemy: bool:
	set(value):
		enemy = value
		%HealthBar.visible = not value
var maxhealth: float
var health: float:
	set(value):
		if value == health:
			return
		health = value
		%HealthBar.ratio = clamp(health / maxhealth, 0, 1)

var skin
var id
var weapon_id:
	set(value):
		if value == weapon_id:
			return
		
		if not enemy and activity.type == "shooting":
			stop_shooting()
		
		weapon_id = value
		weapon = Weapons.weapons[weapon_id]
		
		$Weapon/Sprite2D.texture = weapon.texture
		
		if weapon.stream is AudioStreamInteractive:
			$ShootInteractive.stream = weapon.stream
			$ShootInteractive.volume_db = weapon.volume_db
		elif weapon.stream != null:
			$Shoot.stream.set_stream(0, weapon.stream)
			$Shoot.volume_db = weapon.volume_db
var weapon: Weapons.Weapon
var activity = { "type": "idle" }:
	set(value):
		if value.type == activity.type:
			return
		
		if activity.type == "shooting":
			stop_shooting()
		
		activity = value
var shot_interactive_at


func is_enemy():
	return enemy


func aim(toward):
	$Weapon.rotation = toward
	$Weapon.scale.y = -1 if toward > 0.5 * PI && toward < 1.5 * PI else 1


func _on_label_resized():
	$Label.position.x = (-$Label.size.x / 2.0 + 0.5) * $Label.scale.x
	%HealthBar.resize_to_fit($Label)


func shoot():
	if weapon_id == "Minigun":
		if activity.type == "idle" or not $ShootInteractive.playing:
			$ShootInteractive.play()
			
			shot_interactive_at = Time.get_ticks_msec()
	elif weapon.stream != null:
		$Shoot.play()


func stop_shooting():
	if weapon_id == "Minigun" and $ShootInteractive.playing:
		if Time.get_ticks_msec() < shot_interactive_at + 20:
			$ShootInteractive.stop()
		else:
			$ShootInteractive.get_stream_playback().switch_to_clip_by_name("Minigun Shutdown")
