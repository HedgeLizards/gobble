extends Node2D

const SKINS_PATH = "res://assets/Gobbles/Skins"
const ENEMY_SKINS_PATH = "res://assets/Knights/Skins"
const Entity = preload("res://scenes/entity.tscn")
const RemoteProjectile = preload("res://scenes/remote_projectile.tscn")
var entities = {}
var remote_projectiles = {}
var world_size = Vector2(1, 1)
var world_tile_size = Vector2(1, 1)

func _ready():
	%Me.get_node("Sprite2D").texture = load("%s/%s" % [SKINS_PATH, WebSocket.local_player_skin])
	
	WebSocket.send({
		"type": "createPlayer",
		"id": WebSocket.local_player_name,
		"skin": WebSocket.local_player_skin,
		"pos": [%Me.position.x / Globals.SCALE, %Me.position.y / Globals.SCALE],
		"aim": %Me.get_node("%Weapon").rotation,
		"health": %Me.health,
		"maxhealth": %Me.maxhealth,
		"weapon": %Me.player_weapons[%Me.weapon_index],
	})

func _physics_process(delta):
	WebSocket.send({
		"type": "updatePlayer",
		"pos": [%Me.position.x / Globals.SCALE, %Me.position.y / Globals.SCALE],
		"aim": %Me.get_node("%Weapon").rotation,
		"health": %Me.health,
		"activity": { "type": "shooting" if Input.is_action_pressed("shoot") else "idle" },
		"weapon": %Me.player_weapons[%Me.weapon_index],
	})

func _unhandled_key_input(event):
	if event.keycode == KEY_ESCAPE and event.pressed and not event.echo:
		WebSocket.socket.close()

func process_data(data):
	if data["type"] == "update":
		update(data["actions"])
	elif data["type"] == "welcome":
		var s = data["world"]["size"]
		world_tile_size = Vector2(s[0], s[1])
		world_size = world_tile_size * Globals.SCALE
		%Me.position = world_size / 2
		var camera = %Me.get_node("Camera2D")
		camera.limit_right = world_size.x
		camera.limit_bottom = world_size.y
		%SwordStone.position = world_size / 2

func update(actions):
	var time = float(Time.get_ticks_usec()) / 1e6
	var shot = {}
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
				entity.id = id
				entity.enemy = action["isEnemy"]
				var sprite = entity.get_node("Sprite2D")
				if entity.enemy:
					sprite.wobble_amplitude = 1.0
					sprite.wobble_speed = 10.0
					sprite.texture = load("%s/%s.png" % [ENEMY_SKINS_PATH, action["skin"]])
				else:
					sprite.texture = load("%s/%s" % [SKINS_PATH, action["skin"]])
					var label = entity.get_node("Label")
					label.text = id
					label.visible = true
				entity.aim(action["aim"])
				entity.skin = action["skin"]
				%Entities.add_child(entity)
				entity.position = pos
				entity.maxhealth = action.maxhealth
			
			entity.health = action.health
			if not entity.enemy:
				entity.activity = action.activity
			entity.weapon_id = action.weapon
			entity.positions.push_back(PositionSnapshot.new(pos, action.get("aim", 0.0), time))
		elif type == "entityDeleted":
			var id = action["id"]
			if entities.has(id):
				entities[id].queue_free()
				entities.erase(id)
		elif type == "projectileCreated":
			var playerId = action["creatorId"]
			if typeof(playerId) == typeof(WebSocket.local_player_name) &&  playerId == WebSocket.local_player_name:
				continue
			if not shot.has(playerId):
				var shooter = entities.get(playerId)
				if shooter:
					shooter.shoot()
				shot[playerId] = true
			
			var bullet = RemoteProjectile.instantiate()
			bullet.set_kind(action.get("kind", "bullet"))
			bullet.position = parse_pos(action["pos"])
			bullet.rotation = action["rotation"]
			bullet.speed = action["speed"]
			bullet.distance = action["distance"]
			bullet.is_enemy = action.get("isEnemy", false)
			bullet.damage = action.get("damage", 0)
			bullet.id = action["id"]
			bullet.playerId = action.get("creatorId")
			%Projectiles.add_child(bullet)
			remote_projectiles[action["id"]] =  bullet
		elif type == "projectileImpacted":
			var playerId = action["creatorId"]
			if typeof(playerId) == typeof(WebSocket.local_player_name) &&  playerId == WebSocket.local_player_name:
				continue
			var p = remote_projectiles.get(action["id"])
			if p:
				p.queue_free()
			remote_projectiles.erase(action["id"])
		elif type == "waveStart":
			$UI.show_notice("Wave " + str(action.waveNum))
		elif type == "waveEnd":
			print("wave " + str(action.waveNum) + " completed")
		else:
			print("unknown action ", action)
			
	

func parse_pos(serverpos):
	return Vector2(serverpos[0], serverpos[1]) * Globals.SCALE

func _process(delta):
	var time = float(Time.get_ticks_usec()) / 1e6
	var drawnTime = time - 0.2
	
	for entity in entities.values():
		if entity.positions.size() < 2:
			continue
		if entity.positions.size() >= 2 && drawnTime >= entity.positions[1].time:
			entity.positions.pop_front()
		var previous_position = entity.position
		if entity.positions.size() < 2:
			entity.position = entity.positions[0].pos
			if not entity.enemy:
				entity.aim(entity.positions[0].aim)
		else:
			var p0 = entity.positions[0]
			var p1 = entity.positions[1]
			var t = (drawnTime - p0.time) / (p1.time - p0.time)
			entity.position = p0.pos * (1-t) + p1.pos * t
			entity.aim(lerp_angle(p0.aim, p1.aim, t))
		entity.get_node("Sprite2D").animate(entity.position, previous_position, delta)

class PositionSnapshot:
	var pos: Vector2
	var aim: float
	var time: float
	func _init(pos, aim, time):
		self.pos = pos
		self.aim = aim
		self.time = time
