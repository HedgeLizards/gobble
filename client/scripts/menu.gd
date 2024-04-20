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
	$VBoxContainer/Identity/Name.text = '' if WebSocket.local_player_name == null else WebSocket.local_player_name
	
	skin_index = (randi() % skins.size()) if WebSocket.local_player_skin == null else skins.find(WebSocket.local_player_skin)
	
	$VBoxContainer/Connection/Host.text = 'localhost:8080' if WebSocket.local_player_host == null else WebSocket.local_player_host

func _unhandled_key_input(event):
	if event.keycode == KEY_ENTER:
		_on_join_pressed()
	elif event.keycode == KEY_ESCAPE && event.pressed && !event.echo:
		get_tree().quit()

func _on_previous_pressed():
	skin_index = (skins.size() if skin_index == 0 else skin_index) - 1

func _on_next_pressed():
	skin_index = (-1 if skin_index == skins.size() - 1 else skin_index) + 1

func _on_join_pressed():
	var local_player_name = $VBoxContainer/Identity/Name.text
	
	if local_player_name.is_empty():
		return
	
	WebSocket.local_player_name = local_player_name
	WebSocket.local_player_skin = skins[skin_index]
	WebSocket.local_player_host = $VBoxContainer/Connection/Host.text
	
	WebSocket.connect_to_host()