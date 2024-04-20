extends Node

var socket: WebSocketPeer = WebSocketPeer.new()
var has_introduced: bool = false

const PLAYER = preload("res://scenes/player.tscn")

func _ready():
	socket.connect_to_url('ws://localhost:8080')

func _physics_process(delta):
	socket.poll()
	
	match socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if not has_introduced:
				send({
					"type": "introduction",
					"player": %Me.playername,
					"pos": [%Me.position.x, %Me.position.y]
				})
				has_introduced = true
			send({
				"type": "player",
				"pos": [%Me.position.x, %Me.position.y]
			})
			while socket.get_available_packet_count() > 0:
				var text: String = socket.get_packet().get_string_from_utf8()
				#print(text)
				var data = JSON.parse_string(text)
				if data["type"] == "state":
					for node in %Players.get_children():
						node.queue_free()
					for name in data["players"]:
						if name == %Me.playername:
							continue
						var player_data = data["players"][name]
						var player = PLAYER.instantiate()
						player.position.x = player_data["pos"][0]
						player.position.y = player_data["pos"][1]
						%Players.add_child(player)
						
				
		WebSocketPeer.STATE_CLOSED:
			print(socket.get_close_code())
			
			set_process(false)

func send(data):
	socket.send_text(JSON.stringify(data))

