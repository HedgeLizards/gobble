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

func place():
	modulate = Color.WHITE
	
	$CollisionShape2D.disabled = false
