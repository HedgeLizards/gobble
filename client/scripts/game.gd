extends Node2D

const SKINS_PATH = "res://assets/Gobbles/Skins"
#const Player = preload("res://scenes/player.tscn")
const Entity = preload("res://scenes/entity.tscn")
const RemoteBullet = preload("res://scenes/remote_bullet.tscn")
var entities = {}
var remote_projectiles = {}
var time = 0
var tick = 0
var drawnTick = 0
var tick_duration = 0.5
var world_size = Vector2(1, 1)
var world_tile_size = Vector2(1, 1)

func _ready():
	%Me.get_node("Sprite2D").texture = load("%s/%s" % [SKINS_PATH, WebSocket.local_player_skin])
	
	WebSocket.send({
		"type": "createPlayer",
		"id": WebSocket.local_player_name,
		"skin": WebSocket.local_player_skin,
		"pos": [%Me.position.x / 16, %Me.position.y / 16]
	})

func _physics_process(delta):
	WebSocket.send({
		"type": "updatePlayer",
		"pos": [%Me.position.x / 16, %Me.position.y / 16]
	})

func _unhandled_key_input(event):
	if event.keycode == KEY_ESCAPE and event.pressed and not event.echo:
		WebSocket.socket.close()

func process_data(data):
	tick += 1
	if data["type"] == "update":
		update(data["actions"])
	elif data["type"] == "welcome":
		var s = data["world"]["size"]
		world_tile_size = Vector2(s[0], s[1])
		world_size = world_tile_size * 16
		%Me.position = world_size / 2
		var camera = %Me.get_node("Camera2D")
		camera.limit_right = world_size.x
		camera.limit_bottom = world_size.y
		%Environment.position = world_size / 2
		tick_duration = data["tickDuration"]
		

func update(actions):
	for action in actions:
		var type = action["type"]
		if type == "entityUpdated":
			var id = action["id"]
			if typeof(id) == typeof(WebSocket.local_player_name) &&  id == WebSocket.local_player_name:
				continue
			var entity
			var pos = parse_pos(action["pos"])
			if entities.has(id):
				entity = entities[id]
			else:
				entity = Entity.instantiate()
				entities[id] = entity
				entity.enemy = action["isEnemy"]
				if entity.enemy:
					entity.get_node("Sprite2D").texture = load("res://assets/Knights/Knight_body.png")
				else:
					entity.get_node("Sprite2D").texture = load("%s/%s" % [SKINS_PATH, action["skin"]])
				entity.skin = action["skin"]
				%Entities.add_child(entity)
				entity.position = pos
			entity.positions.push_back(PositionSnapshot.new(pos, tick))
		elif type == "entityDeleted":
			var id = action["id"]
			entities[id].queue_free()
			entities.erase(id)
		elif type == "projectileCreated":
			var playerId = action["playerId"]
			if typeof(playerId) == typeof(WebSocket.local_player_name) &&  playerId == WebSocket.local_player_name:
				continue
			var bullet = RemoteBullet.instantiate()
			bullet.position = parse_pos(action["pos"])
			bullet.rotation = action["rotation"]
			bullet.speed = action["speed"]
			%Projectiles.add_child(bullet)
			print("new bullet ", bullet.position)
			remote_projectiles[action["id"]] =  bullet
		elif type == "projectileRemoved":
			var playerId = action["playerId"]
			if typeof(playerId) == typeof(WebSocket.local_player_name) &&  playerId == WebSocket.local_player_name:
				continue
			var p = remote_projectiles.get(action["id"])
			if p:
				p.queue_free()
			remote_projectiles.erase(action["id"])
		else:
			print("unknown action ", action)
		#elif type == "enemyUpdated":
			#var id = action["id"]
			#var enemy
			#var pos = parse_pos(action["pos"])
			#if enemies.has(id):
				#enemy = enemies[id]
			#else:
				#enemy = Enemy.instantiate()
				#enemies[id] = enemy
				#%Enemies.add_child(enemy)
				#enemy.position = pos
			#enemy.positions.push_back(PositionSnapshot.new(pos, tick))
			##enemy.position = pos
	

func parse_pos(serverpos):
	return Vector2(serverpos[0], serverpos[1]) * 16

func _process(delta):
	var catchup = 1
	if tick - drawnTick > 2:
		catchup *= 1.2
	elif tick - drawnTick < 1:
		catchup *= 0.8
	drawnTick += delta / tick_duration * catchup
	
	for entity in entities.values():
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
