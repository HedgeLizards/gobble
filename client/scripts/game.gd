extends Node

var socket: WebSocketPeer = WebSocketPeer.new()
var playername: String
var has_introduced: bool = false



func _ready():
	socket.connect_to_url('ws://localhost:8080')
	playername = "player" + str(randi()) # todo: random name gen or choosing

func _physics_process(delta):
	socket.poll()
	
	match socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if not has_introduced:
				send({
					"type": "introduction",
					"player": playername,
					"pos": {"x": %Player.position.x, "y": %Player.position.y}
				})
				has_introduced = true
			send({
				"type": "player",
				"pos": {"x": %Player.position.x, "y": %Player.position.y}
			})
			while socket.get_available_packet_count() > 0:
				print(socket.get_packet().get_string_from_utf8())
		WebSocketPeer.STATE_CLOSED:
			print(socket.get_close_code())
			
			set_process(false)

func send(data):
	socket.send_text(JSON.stringify(data))

