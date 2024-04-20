extends Node2D

const Player = preload("res://scenes/player.tscn")
const Enemy = preload("res://scenes/enemy.tscn")
var players = {}
var enemies = {}
var time = 0
var tick = 0
var drawnTick = 0
var tps = 20

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
	tick += 1
	for action in data:
		var type = action["type"]
		if type == "playerUpdated":
			var id = action["id"]
			if id == WebSocket.local_player_name:
				continue
			var player
			var pos = parse_pos(action["pos"])
			if players.has(id):
				player = players[id]
			else:
				player = Player.instantiate()
				players[id] = player
				%Players.add_child(player)
				player.position = pos
			player.position = parse_pos(action["pos"])
		elif type == "playerDeleted":
			var id = action["id"]
			players[id].queue_free()
			players.erase[id]
		elif type == "enemyUpdated":
			var id = action["id"]
			var enemy
			var pos = parse_pos(action["pos"])
			if enemies.has(id):
				enemy = enemies[id]
			else:
				enemy = Enemy.instantiate()
				enemies[id] = enemy
				%Enemies.add_child(enemy)
				enemy.position = pos
			enemy.positions.push_back(PositionSnapshot.new(pos, tick))
			#enemy.position = pos
	

func parse_pos(serverpos):
	return Vector2(serverpos[0], serverpos[1]) * 16

func _process(delta):
	var catchup = 1
	if tick - drawnTick > 2:
		catchup *= 1.2
	elif tick - drawnTick < 1:
		catchup *= 0.8
	drawnTick += delta * tps * catchup
	
	for entity in enemies.values() + players.values():
		if entity.positions.size() < 2:
			continue
		if entity.positions.size() >= 2 && drawnTick >= entity.positions[1].tick:
			entity.positions.pop_front()
		if entity.positions.size() < 2:
			entity.position = entity.positions[0].pos
		else:
			var p0 = entity.positions[0]
			var p1 = entity.positions[1]
			var t = (drawnTick - p0.tick) / (p1.tick - p0.tick)
			entity.position = p0.pos * (1-t) + p1.pos * t

class PositionSnapshot:
	var pos: Vector2
	var tick: float
	func _init(pos, tick):
		self.pos = pos
		self.tick = tick
