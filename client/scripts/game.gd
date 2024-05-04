extends Node2D

const SKINS_PATH = "res://assets/Gobbles/Skins"
const ENEMY_SKINS_PATH = "res://assets/Knights/Skins"
const Entity = preload("res://scenes/remote_entity.tscn")
const RemoteProjectile = preload("res://scenes/remote_projectile.tscn")
const Shockwave = preload("res://scenes/shockwave.tscn")
var entities = {}
var remote_projectiles = {}
var world_size = Vector2(1, 1)
var world_tile_size = Vector2(1, 1)

func _ready():
	%Me.get_node("Sprite2D").texture = load("%s/%s" % [SKINS_PATH, WebSocket.local_player_skin])
	
	WebSocket.send({
		"type": "createPlayer",
		"id": WebSocket.local_player_id,
		"name": WebSocket.local_player_name,
		"skin": WebSocket.local_player_skin,
		"maxhealth": %Me.maxhealth,
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
			if id == WebSocket.local_player_id:
				if not %Me.is_alive():
					%Me.position = parse_pos(action.pos)
				%Me.health = action.health
				%Me.alive = action.alive
				continue
			var entity
			var pos = parse_pos(action.pos)
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
					label.text = action.name
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
			if id == WebSocket.local_player_id:
				%Me.alive = false
			if entities.has(id):
				entities[id].queue_free()
				entities.erase(id)
		elif type == "projectileCreated":
			var playerId = action["creatorId"]
			if playerId == WebSocket.local_player_id:
				continue
			if not shot.has(playerId):
				var shooter = entities.get(playerId)
				if shooter:
					shooter.shoot()
				shot[playerId] = true
			
			var projectile = RemoteProjectile.instantiate()
			projectile.weapon_id = action["weapon"]
			projectile.position = parse_pos(action["pos"])
			projectile.rotation = action["rotation"]
			projectile.is_enemy = action.get("isEnemy", false)
			projectile.id = action["id"]
			projectile.playerId = action.get("creatorId")
			%Projectiles.add_child(projectile)
			remote_projectiles[action["id"]] = projectile
		elif type == "projectileImpacted":
			var playerId = action["creatorId"]
			if playerId == WebSocket.local_player_id:
				continue
			var p = remote_projectiles.get(action["id"])
			if p:
				if action["weapon"] == "GrenadeLauncher":
					var shockwave = Shockwave.instantiate()
					shockwave.monitoring = false
					shockwave.position = parse_pos(action["pos"])
					shockwave.z_index = 1
					%Projectiles.add_child(shockwave)
				p.queue_free()
			remote_projectiles.erase(action["id"])
		elif type == "waveStart":
			$UI.show_notice("Wave " + str(action.waveNum))
		elif type == "waveEnd":
			$UI.show_notice("Wave " + str(action.waveNum) + " completed!")
		elif type == "gameOver":
			$UI.show_notice("Game over!")
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
