extends CanvasLayer

static var card_set

static func _static_init():
	var atlas_texture1 = AtlasTexture.new()
	
	atlas_texture1.atlas = preload('res://assets/Buildings/Building_Armory_Spritesheet.png')
	atlas_texture1.region = Rect2(64, 0, 16, 32)
	
	var atlas_texture2 = AtlasTexture.new()
	
	atlas_texture2.atlas = preload('res://assets/Buildings/Building_Bank_Spritesheet.png')
	atlas_texture2.region = Rect2(96, 0, 16, 16)
	
	card_set = [
		{
			'cost': 30,
			'title': 'Armory',
			'texture': atlas_texture1,
			'description': 'Visit the armory to buy stronger guns.',
			'scene': preload('res://scenes/Buildings/armory.tscn'),
		},
		{
			'cost': 20,
			'title': 'Bank',
			'texture': atlas_texture2,
			'description': 'Visit the bank to cash in, or wait for exponential growth.',
			'scene': preload('res://scenes/Buildings/bank.tscn'),
		},
		{
			'cost': 10,
			'title': 'Wall',
			'texture': preload('res://assets/World/Stone_wall_obstacle_3.png'),
			'description': 'Protects you and the golden sword.',
			'scene': preload('res://scenes/Buildings/wall.tscn'),
		},
	]

var gold = -1:
	set(value):
		if value > gold && gold != -1:
			if tween != null:
				tween.kill()
			
			tween = create_tween().set_trans(Tween.TRANS_SINE)
			tween.tween_property($Gold, 'scale', Vector2.ONE * (1.0 + (value - gold) * 0.2), 0.2).set_ease(Tween.EASE_OUT)
			tween.tween_property($Gold, 'scale', Vector2.ONE, 0.2).set_ease(Tween.EASE_IN)
		
		gold = value
		
		$Gold/Label.text = str(gold)
		
		if !$Cards.card_sets.is_empty():
			$Cards.update_cards()
var tween
var building = false:
	set(value):
		building = value
		
		if building:
			$Cards.add_card_set(card_set, true, func(index): card = card_set[index])
		elif placing == null:
			$Cards.remove_card_set(card_set)
		else:
			placing = null
var card:
	set(value):
		card = value
		
		placing = card.scene.instantiate()
var placing:
	set(value):
		if placing == null:
			$Cards.remove_card_set(card_set)
			
			if !$Cards.card_sets.is_empty():
				$Cards.visible = false
			
			$'../Buildings'.add_child(value)
			
			set_process(true)
			set_process_unhandled_input(true)
			
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		else:
			$Cards.visible = true
			
			set_process(false)
			set_process_unhandled_input(false)
			
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			
			placing.queue_free()
		
		placing = value
var grid = []

@onready var viewport = get_viewport()

func _ready():
	var screen_scale = DisplayServer.screen_get_scale()
	
	$Gold.add_theme_constant_override('separation',
		$Gold.get_theme_constant('separation') * screen_scale
	)
	$Gold/TextureRect.custom_minimum_size *= screen_scale
	$Gold/Label.add_theme_font_size_override('font_size',
		$Gold/Label.get_theme_font_size('font_size') * screen_scale
	)
	
	$Notice.add_theme_font_size_override('normal_font_size',
		$Notice.get_theme_font_size('normal_font_size') * screen_scale
	)
	
	set_process(false)
	set_process_unhandled_input(false)

func _on_gold_gui_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		var me = $'../Me'
		
		if me.alive:
			building = !building
			
			me.was_placing_building = true # so you don't shoot when clicking the Control

func _on_gold_resized():
	$Gold.pivot_offset = $Gold.size / 2.0

func show_notice(notice, seconds = 2.0):
	$Notice.text = notice
	$Notice.modulate.a = 1.0
	
	if seconds != null:
		$Notice/Timer.start(seconds)
	elif !$Notice/Timer.is_stopped():
		$Notice/Timer.stop()

func hide_notice():
	create_tween().set_trans(Tween.TRANS_SINE).tween_property($Notice, 'modulate:a', 0.0, 0.5)

func _process(_delta):
	var canvas_transform = viewport.canvas_transform
	var world_mouse_position = (viewport.get_mouse_position() - canvas_transform.origin) / Vector2(canvas_transform.x.x, canvas_transform.y.y)
	
	placing.cell = floor((world_mouse_position - (placing.SIZE - Vector2.ONE) / 2.0 * Globals.SCALE) / Globals.SCALE)
	
	if placing.cell.x < 0 || placing.cell.x + placing.SIZE.x >= grid[0].size() || placing.cell.y < 0 || placing.cell.y + placing.SIZE.y >= grid.size():
		placing.blocked = true
		
		return
	
	for r in placing.SIZE.y:
		for c in placing.SIZE.x:
			if grid[placing.cell.y + r][placing.cell.x + c] != null:
				placing.blocked = true
				
				return
	
	placing.blocked = false

func _unhandled_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		if placing.blocked:
			return
		
		WebSocket.send({
			'type': 'createBuilding',
			'cost': card.cost,
			'kind': card.title,
			'pos': [placing.cell.x, placing.cell.y],
		})
		
		# play sound
		
		if !event.shift_pressed || card.cost * 2 > gold:
			building = false

func add_building_to_grid(instance):
	instance.place()
	
	for r in instance.SIZE.y:
		for c in instance.SIZE.x:
			grid[instance.cell.y + r][instance.cell.x + c] = instance

func remove_building_from_grid(instance):
	for r in instance.SIZE.y:
		for c in instance.SIZE.x:
			grid[instance.cell.y + r][instance.cell.x + c] = null
