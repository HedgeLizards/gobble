extends Node

var socket = WebSocketPeer.new()
var local_player_name
var connecting = true

func _ready():
	set_physics_process(false)

func connect_to_host(host):
	var result = socket.connect_to_url('ws://' + host)
	
	if result != Error.OK:
		print(result)
	
	set_physics_process(true)

func _physics_process(delta):
	socket.poll()
	
	match socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if connecting:
				connecting = false
				
				get_tree().change_scene_to_packed(preload('res://scenes/game.tscn'))
			else:
				while socket.get_available_packet_count() > 0:
					$'../Game'.process_data(JSON.parse_string(socket.get_packet().get_string_from_utf8()))
		WebSocketPeer.STATE_CLOSED:
			print(socket.get_close_reason())
			
			get_tree().change_scene_to_packed(preload('res://scenes/menu.tscn'))
			
			set_physics_process(false)

func send(data):
	socket.send_text(JSON.stringify(data))
