extends Node2D

const PLAYER = preload("res://scenes/player.tscn")
var players = {}

func _ready():
	WebSocket.send({
		"type": "createPlayer",
		"id": WebSocket.local_player_name,
		"pos": [%Me.position.x, %Me.position.y]
	})

func _physics_process(delta):
	WebSocket.send({
		"type": "updatePlayer",
		"pos": [%Me.position.x, %Me.position.y]
	})

func process_data(data):
	for action in data:
		var type = action["type"]
		if type == "playerCreated":
			var id = action["id"]
			if id == WebSocket.local_player_name:
				continue
			var player = PLAYER.instantiate()
			players[id] = player
			player.position.x = action["pos"][0]
			player.position.y = action["pos"][1]
			%Players.add_child(player)
		elif type == "playerUpdated":
			var id = action["id"]
			if id == WebSocket.local_player_name:
				continue
			var player
			if players.has(id):
				player = players[id]
			else:
				player = PLAYER.instantiate()
				players[id] = player
				%Players.add_child(player)
			player.position.x = action["pos"][0]
			player.position.y = action["pos"][1]
		elif type == "playerDeleted":
			var id = action["id"]
			players[id].queue_free()
			players.erase[id]
