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
