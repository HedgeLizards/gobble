extends StaticBody2D

const SIZE = Vector2(1, 1)

var cell:
	set(value):
		cell = value
		
		position = (cell + SIZE / Vector2(2.0, 1.0)) * Globals.SCALE
var blocked:
	set(value):
		blocked = value
		
		modulate = Color.RED if blocked else Color.GREEN
var health:
	set(value):
		health = value
		
		$HealthBar.ratio = health / 20.0
		
		if health == 0:
			$CollisionShape2D.disabled = true

@onready var ui = $'../../UI'

func place():
	modulate = Color.WHITE
	
	$CollisionShape2D.disabled = false

func _on_mouse_entered():
	if ui.placing == null:
		$HealthBar.visible = true

func _on_mouse_exited():
	$HealthBar.visible = false
