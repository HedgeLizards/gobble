extends Control

const SKINS_PATH = 'res://assets/Gobbles/Skins'

static var skins = []
static var default_host := "localhost"
static var multiply_default_stylebox_sizes_by_screen_scale = true

static func _static_init():
	for filename in DirAccess.get_files_at(SKINS_PATH):
		var substrings = filename.split('.import')
		
		if substrings.size() == 2:
			skins.push_back(substrings[0])
	
	var file := FileAccess.open("res://default_host.txt", FileAccess.READ)
	if file != null:
		default_host = file.get_as_text()
	else:
		var location = JavaScriptBridge.get_interface("location")
		if location:
			default_host = location.hostname

var skin_index:
	set(value):
		skin_index = value
		
		$VBoxContainer/Identity/Skin.texture = load('%s/%s' % [SKINS_PATH, skins[skin_index]])

func _ready():
	Input.set_custom_mouse_cursor(null)
	
	var screen_scale = DisplayServer.screen_get_scale()
	
	if multiply_default_stylebox_sizes_by_screen_scale:
		multiply_default_stylebox_sizes_by_screen_scale = false
		
		var stylebox_focus = $VBoxContainer/Identity/Name.get_theme_stylebox('focus')
		var stylebox_normal = $VBoxContainer/Identity/Name.get_theme_stylebox('normal')
		
		stylebox_focus.border_width_left *= screen_scale
		stylebox_focus.border_width_top *= screen_scale
		stylebox_focus.border_width_right *= screen_scale
		stylebox_focus.border_width_bottom *= screen_scale
		stylebox_focus.corner_radius_top_left *= screen_scale
		stylebox_focus.corner_radius_top_right *= screen_scale
		stylebox_focus.corner_radius_bottom_left *= screen_scale
		stylebox_focus.corner_radius_bottom_right *= screen_scale
		stylebox_focus.expand_margin_left *= screen_scale
		stylebox_focus.expand_margin_top *= screen_scale
		stylebox_focus.expand_margin_right *= screen_scale
		stylebox_focus.expand_margin_bottom *= screen_scale
		stylebox_focus.content_margin_left *= screen_scale
		stylebox_focus.content_margin_top *= screen_scale
		stylebox_focus.content_margin_right *= screen_scale
		stylebox_focus.content_margin_bottom *= screen_scale
		
		stylebox_normal.border_width_bottom *= screen_scale
		stylebox_normal.corner_radius_top_left *= screen_scale
		stylebox_normal.corner_radius_top_right *= screen_scale
		stylebox_normal.corner_radius_bottom_left *= screen_scale
		stylebox_normal.corner_radius_bottom_right *= screen_scale
		stylebox_normal.content_margin_left *= screen_scale
		stylebox_normal.content_margin_top *= screen_scale
		stylebox_normal.content_margin_right *= screen_scale
		stylebox_normal.content_margin_bottom *= screen_scale
	
	$VBoxContainer.add_theme_constant_override('separation',
		$VBoxContainer.get_theme_constant('separation') * screen_scale
	)
	
	$VBoxContainer/Identity.add_theme_constant_override('separation',
		$VBoxContainer/Identity.get_theme_constant('separation') * screen_scale
	)
	$VBoxContainer/Identity/Name.add_theme_font_size_override('font_size',
		$VBoxContainer/Identity/Name.get_theme_font_size('font_size') * screen_scale
	)
	$VBoxContainer/Identity/Previous.custom_minimum_size *= screen_scale
	$VBoxContainer/Identity/Skin.custom_minimum_size *= screen_scale
	$VBoxContainer/Identity/Next.custom_minimum_size *= screen_scale
	
	$VBoxContainer/Error.custom_minimum_size *= screen_scale
	$VBoxContainer/Error.add_theme_font_size_override('font_size',
		$VBoxContainer/Error.get_theme_font_size('font_size') * screen_scale
	)
	
	$VBoxContainer/Connection.add_theme_constant_override('separation',
		$VBoxContainer/Connection.get_theme_constant('separation') * screen_scale
	)
	$VBoxContainer/Connection/Host.add_theme_font_size_override('font_size',
		$VBoxContainer/Connection/Host.get_theme_font_size('font_size') * screen_scale
	)
	$VBoxContainer/Connection/Port.add_theme_font_size_override('font_size',
		$VBoxContainer/Connection/Port.get_theme_font_size('font_size') * screen_scale
	)
	$VBoxContainer/Connection/Join.add_theme_font_size_override('font_size',
		$VBoxContainer/Connection/Join.get_theme_font_size('font_size') * screen_scale
	)
	
	if WebSocket.local_player_name != null:
		$VBoxContainer/Identity/Name.text = WebSocket.local_player_name
		$VBoxContainer/Identity/Name.caret_column = WebSocket.local_player_name.length()
	
	$VBoxContainer/Identity/Name.grab_focus()
	
	skin_index = (randi() % skins.size()) if WebSocket.local_player_skin == null else skins.find(WebSocket.local_player_skin)
	
	if WebSocket.local_player_error != null:
		$VBoxContainer/Error.text = WebSocket.local_player_error
		$VBoxContainer/Error.visible = true
	
	$VBoxContainer/Connection/Host.text = default_host if WebSocket.local_player_host == null else WebSocket.local_player_host
	$VBoxContainer/Connection/Port.text = '9412' if WebSocket.local_player_port == null else WebSocket.local_player_port

func _unhandled_key_input(event):
	if !event.pressed || event.echo:
		return
	
	match event.keycode:
		KEY_ESCAPE:
			get_tree().quit()
		KEY_ENTER:
			$VBoxContainer/Identity/Name.grab_focus()
		KEY_LEFT:
			_on_previous_pressed()
		KEY_RIGHT:
			_on_next_pressed()

func _on_text_changed(_new_text):
	$"UI Audio/AudioStreamPlayer Typing".play()

func _on_text_submitted(new_text):
	_on_join_pressed()

func _on_previous_pressed():
	skin_index = (skins.size() if skin_index == 0 else skin_index) - 1
	$"UI Audio/AudioStreamPlayer Arrow Click".play()

func _on_next_pressed():
	skin_index = (-1 if skin_index == skins.size() - 1 else skin_index) + 1
	$"UI Audio/AudioStreamPlayer Arrow Click".play()

func _on_join_pressed():
	var local_player_name = $VBoxContainer/Identity/Name.text
	$"UI Audio/AudioStreamPlayer Join Click".play()
	
	WebSocket.local_player_name = generate_random_name() if local_player_name.is_empty() else local_player_name
	WebSocket.local_player_id = "P:" + WebSocket.local_player_name.to_lower()
	WebSocket.local_player_skin = skins[skin_index]
	WebSocket.local_player_host = $VBoxContainer/Connection/Host.text
	WebSocket.local_player_port = $VBoxContainer/Connection/Port.text
	
	WebSocket.connect_to_host($VBoxContainer/Error)


func generate_random_name() -> String:
	var vowels = Array("aaaaeeeeeeiiioooouu".split())
	var consonants = Array("bbccdddffgghhjjkkllmmmnnnnppqrrrrsssstttttvvwxyz".split())

	var name = ""
	for i in randi_range(2, 4):
		if randf() > 0.5:
			name += consonants.pick_random()
		name += vowels.pick_random()
		if randf() > 0.5:
			name += consonants.pick_random()
	return name.capitalize()
