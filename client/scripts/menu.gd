extends Control

const SKINS_PATH = 'res://assets/Gobbles/Skins'

static var skins = []

static func _static_init():
	for filename in DirAccess.get_files_at(SKINS_PATH):
		var substrings = filename.split('.import')
		
		if substrings.size() == 2:
			skins.push_back(substrings[0])

var skin_index:
	set(value):
		skin_index = value
		
		$VBoxContainer/Identity/Skin.texture = load('%s/%s' % [SKINS_PATH, skins[skin_index]])

func _ready():
	scale *= DisplayServer.screen_get_scale()

	$VBoxContainer/Identity/Name.text = generate_random_name() if WebSocket.local_player_name == null else WebSocket.local_player_name
	$VBoxContainer/Identity/Name.caret_column = $VBoxContainer/Identity/Name.text.length()
	$VBoxContainer/Identity/Name.grab_focus()
	
	skin_index = (randi() % skins.size()) if WebSocket.local_player_skin == null else skins.find(WebSocket.local_player_skin)
	
	if WebSocket.local_player_error != null:
		$VBoxContainer/Error.text = WebSocket.local_player_error
		$VBoxContainer/Error.visible = true
	
	$VBoxContainer/Connection/Host.text = 'localhost' if WebSocket.local_player_host == null else WebSocket.local_player_host
	$VBoxContainer/Connection/Port.text = '9412' if WebSocket.local_player_port == null else WebSocket.local_player_port

func _unhandled_key_input(event):
	match event.keycode:
		KEY_ESCAPE:
			if event.pressed && !event.echo:
				get_tree().quit()
		KEY_ENTER:
			if $VBoxContainer/Identity/Name.has_focus():
				_on_join_pressed()
	
	# PLEASE NOTE:
	# I expect this sound to also play in-game, but that should not be the case.
	$"UI Audio/AudioStreamPlayer Typing".play()

func _on_previous_pressed():
	skin_index = (skins.size() if skin_index == 0 else skin_index) - 1
	$"UI Audio/AudioStreamPlayer Arrow Click".play()

func _on_next_pressed():
	skin_index = (-1 if skin_index == skins.size() - 1 else skin_index) + 1
	$"UI Audio/AudioStreamPlayer Arrow Click".play()

func _on_join_pressed():
	var local_player_name = $VBoxContainer/Identity/Name.text
	$"UI Audio/AudioStreamPlayer Join Click".play()
	
	if local_player_name.is_empty():
		return
	
	WebSocket.local_player_name = local_player_name
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
	return name

