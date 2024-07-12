extends StaticBody2D

const SIZE = Vector2(1, 2)

static var card_set = [
	{
		'cost': 0,
		'title': 'Pistol',
		'texture': preload('res://assets/Gobbles/Weapons/Gobble_Gun.png'),
		'description': 'Shoots.',
		'id': 'Handgun',
		'disabled': true,
	},
	{
		'cost': 35,
		'title': 'Rifle',
		'texture': preload('res://assets/Gobbles/Weapons/Gobble_Assault_Rifle.png'),
		'description': 'Shoots faster.',
		'id': 'AssaultRifle',
	},
	{
		'cost': 80,
		'title': 'Minigun',
		'texture': preload('res://assets/Gobbles/Weapons/Gobble_Minigun.png'),
		'description': 'Shoots even faster, but less accurate.',
		'id': 'Minigun',
	},
	{
		'cost': 20,
		'title': 'Sniper',
		'texture': preload('res://assets/Gobbles/Weapons/Gobble_Sniper.png'),
		'description': 'Shoots farther, and zooms out.',
		'id': 'Sniper',
	},
	{
		'cost': 50,
		'title': 'Shotgun',
		'texture': preload('res://assets/Gobbles/Weapons/Gobble_Shotgun.png'),
		'description': 'Shoots multiple bullets per shot.',
		'id': 'Shotgun',
	},
	{
		'cost': 65,
		'title': 'Launcher',
		'texture': preload('res://assets/Gobbles/Weapons/Gobble_Granande_Launcher.png'),
		'description': 'Shoots grenades with area damage.',
		'id': 'GrenadeLauncher',
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
		
		$HealthBar.ratio = health / 20.0
		
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
	ui_cards.add_card_set(card_set, false, func(index):
		var card = card_set[index]
		
		if card.cost > 0:
			WebSocket.send({
				'type': 'buyGun',
				'cost': card.cost,
				'buyerId': WebSocket.local_player_id,
				'weapon': card.id,
			})
			
			# play sound
		else:
			me.weapon_id = card.id
			
			for c in card_set:
				if c.erase('disabled'):
					break
			
			card.disabled = true
			
			ui_cards.update_cards()
		
		me.was_placing_building = true # so you don't shoot when clicking the Control
	)

func _on_area_2d_body_exited(body):
	ui_cards.remove_card_set(card_set)
