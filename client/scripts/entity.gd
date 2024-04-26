extends Area2D

var positions = []
var enemy: bool:
	set(value):
		enemy = value
		%HealthBar.visible = not value
var maxhealth: float
var health: float:
	set(value):
		health = value
		var ratio := clamp(health / maxhealth, 0, 1)
		%HealthBar/Healthy.size.x = %HealthBar.size.x * ratio

var skin
var id
var weapon:
	set(value):
		if weapon == value:
			return
		
		weapon = value
		
		$Weapon/Sprite2D.texture = weapon.texture
		
		if not weapon.stream is AudioStreamInteractive and weapon.stream != null:
			$Shoot.stream.set_stream(0, weapon.stream)
			$Shoot.volume_db = weapon.volume_db


func is_enemy():
	return enemy


func aim(toward):
	$Weapon.rotation = toward
	$Weapon.scale.y = -1 if toward > 0.5 * PI && toward < 1.5 * PI else 1


func _on_label_resized():
	$Label.position.x = (-$Label.size.x / 2.0 + 0.5) * $Label.scale.x


func shoot():
	if not weapon.stream is AudioStreamInteractive and weapon.stream != null:
		$Shoot.play()
