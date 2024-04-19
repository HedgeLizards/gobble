extends Node

var socket = WebSocketPeer.new()

func _ready():
	socket.connect_to_url('ws://localhost:8080')

func _process(_delta):
	socket.poll()
	
	match socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count() > 0:
				print(socket.get_packet().get_string_from_utf8())
		WebSocketPeer.STATE_CLOSED:
			print(socket.get_close_code())
			
			set_process(false)
