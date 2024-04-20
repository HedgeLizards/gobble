extends Node

var socket = WebSocketPeer.new()
var local_player_name
var local_player_skin
var connecting = false

func _ready():
	set_physics_process(false)

func connect_to_host(host):
	if connecting:
		return
	
	var result = socket.connect_to_url('ws://' + host)
	
	if result != Error.OK:
		print(result)
		
		return
	
	connecting = true
	
	set_physics_process(true)

func _physics_process(delta):
	socket.poll()
	
	match socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if connecting:
				get_tree().change_scene_to_packed(preload('res://scenes/game.tscn'))
				
				connecting = false
			else:
				var game = get_node_or_null('../Game')
				
				if game != null:
					while socket.get_available_packet_count() > 0:
						game.process_data(JSON.parse_string(socket.get_packet().get_string_from_utf8()))
		WebSocketPeer.STATE_CLOSED:
			print(socket.get_close_reason())
			
			get_tree().change_scene_to_packed(preload('res://scenes/menu.tscn'))
			
			connecting = false
			
			set_physics_process(false)

func send(message):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify(message))
