extends StaticBody2D

const SIZE = Vector2(1, 1)

var card_set = [
	{
		'cost': 1,
		'title': 'Cash In',
		'texture': preload('res://assets/UI/spr_Coin_Final_UI.png'),
		'description': 'Current interest: 1.',
	},
]

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
		
		$HealthBar.ratio = health / 10.0
		
		if health == 0:
			$CollisionShape2D.disabled = true
			$Area2D.monitoring = false

@onready var ui = $'../../UI'
@onready var ui_cards = ui.get_node('Cards')
@onready var me = $'../../Me'

func place():
	modulate = Color.WHITE
	
	$CollisionShape2D.disabled = false
	$AnimatedSprite2D.play()
	$Area2D.monitoring = true

func _on_mouse_entered():
	if ui.placing == null:
		$HealthBar.visible = true

func _on_mouse_exited():
	$HealthBar.visible = false

func _on_area_2d_body_entered(body):
	ui_cards.add_card_set(card_set, false, func(_index):
		WebSocket.send({
			'type': 'emptyBank',
			'pos': [cell.x, cell.y],
		})
		
		# play sound
		
		me.was_placing_building = true # so you don't shoot when clicking the Control
	)

func _on_area_2d_body_exited(body):
	ui_cards.remove_card_set(card_set)
