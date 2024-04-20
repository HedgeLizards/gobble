extends Node2D

const PLAYER = preload("res://scenes/player.tscn")

func _ready():
	WebSocket.send({
		"type": "introduction",
		"player": WebSocket.local_player_name,
		"pos": [%Me.position.x, %Me.position.y]
	})

func _physics_process(delta):
	WebSocket.send({
		"type": "player",
		"pos": [%Me.position.x, %Me.position.y]
	})

func process_data(data):
	if data["type"] == "state":
		for node in %Players.get_children():
			node.queue_free()
		for name in data["players"]:
			if name == WebSocket.local_player_name:
				continue
			var player_data = data["players"][name]
			var player = PLAYER.instantiate()
			player.position.x = player_data["pos"][0]
			player.position.y = player_data["pos"][1]
			%Players.add_child(player)
