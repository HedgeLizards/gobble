extends Area2D

var positions = []
var enemy: bool = false
var health = 10
var skin
var id


func is_enemy():
	return enemy


func aim(towards):
	$Weapon.rotation = towards
	$Weapon.scale.y = -1 if towards > 0.5 * PI && towards < 1.5 * PI else 1


func _on_label_resized():
	$Label.position.x = (-$Label.size.x / 2.0 + 0.5) * $Label.scale.x

func shoot():
	print("shooting from ", id)
