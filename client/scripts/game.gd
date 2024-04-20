extends Node2D

const Player = preload("res://scenes/player.tscn")
const Enemy = preload("res://scenes/enemy.tscn")
var players = {}
var enemies = {}

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

func _unhandled_key_input(event):
	if event.keycode == KEY_ESCAPE and event.pressed and not event.echo:
		WebSocket.socket.close()

func process_data(data):
	for action in data:
		var type = action["type"]
		if type == "playerUpdated":
			var id = action["id"]
			if id == WebSocket.local_player_name:
				continue
			var player
			if players.has(id):
				player = players[id]
			else:
				player = Player.instantiate()
				players[id] = player
				%Players.add_child(player)
			player.position = parse_pos(action["pos"])
		elif type == "playerDeleted":
			var id = action["id"]
			players[id].queue_free()
			players.erase(id)
		elif type == "enemyUpdated":
			var id = action["id"]
			var enemy
			if enemies.has(id):
				enemy = enemies[id]
			else:
				enemy = Enemy.instantiate()
				enemies[id] = enemy
				%Enemies.add_child(enemy)
			enemy.position = parse_pos(action["pos"])

func parse_pos(serverpos):
	return Vector2(serverpos[0], serverpos[1]) * 16
