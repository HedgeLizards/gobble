extends Node

var socket = WebSocketPeer.new()
var local_player_name
var local_player_skin
var local_player_error
var local_player_host
var local_player_port
var connecting = false

func _ready():
	set_physics_process(false)

func connect_to_host(error):
	if connecting:
		return
	
	var result = socket.connect_to_url('ws://%s:%s' % [local_player_host, local_player_port])
	
	if result == OK:
		error.text = ''
	else:
		error.text = error_string(result)
		error.visible = true
		
		return
	
	connecting = true
	
	set_physics_process(true)

func _physics_process(delta):
	socket.poll()
	
	match socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if connecting:
				get_tree().change_scene_to_packed(preload('res://scenes/game.tscn'))
				
				local_player_error = null
				
				connecting = false
			else:
				var game = get_node_or_null('../Game')
				
				if game != null:
					while socket.get_available_packet_count() > 0:
						game.process_data(JSON.parse_string(socket.get_packet().get_string_from_utf8()))
		WebSocketPeer.STATE_CLOSED:
			var close_code = socket.get_close_code()
			
			if close_code == -1:
				local_player_error = 'Server down'
			elif close_code > 1001:
				local_player_error = '%s %s' % [close_code, socket.get_close_reason()]
			
			var error = get_node_or_null('../Menu/VBoxContainer/Error')
			
			if error == null:
				get_tree().change_scene_to_packed(preload('res://scenes/menu.tscn'))
			else:
				error.text = local_player_error
				error.visible = true
				
				connecting = false
			
			set_physics_process(false)

func send(message):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify(message))
