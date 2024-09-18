extends Node2D

const SKINS_PATH = "res://assets/Gobbles/Skins"
const ENEMY_SKINS_PATH = "res://assets/Knights/Skins"
const Entity = preload("res://scenes/remote_entity.tscn")
const RemoteProjectile = preload("res://scenes/remote_projectile.tscn")
const Shockwave = preload("res://scenes/shockwave.tscn")
const CoinParticles = preload("res://scenes/Particles/coin_particles.tscn")
const buildings = {
	"SwordStone": preload("res://scenes/Buildings/sword_stone.tscn"),
	"Armory": preload("res://scenes/Buildings/armory.tscn"),
	"Bank": preload("res://scenes/Buildings/bank.tscn"),
	"Wall": preload("res://scenes/Buildings/wall.tscn"),
}
const Armory = preload("res://scripts/armory.gd")

var entities = {}
var remote_projectiles = {}
var world_size = Vector2(1, 1)
var world_tile_size = Vector2(1, 1)

func _init():
	visible = false

func _ready():
	Input.set_custom_mouse_cursor(preload("res://assets/UI/UI_Crosshair_1.png"), Input.CURSOR_ARROW, Vector2(5, 5))
	
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

func _exit_tree():
	for card in Armory.card_set:
		card.cost = card.get("originalCost", card.cost)
		card.erase("originalCost")
		
		if card.id == "Handgun":
			card.disabled = true
		else:
			card.erase("disabled")

func process_data(data):
	if data["type"] == "update":
		update(data["actions"])
	elif data["type"] == "welcome":
		var s = data["world"]["size"]
		world_tile_size = Vector2(s[0], s[1])
		world_size = world_tile_size * Globals.SCALE
		%Me.position = world_size / 2.0 + Vector2(0.0, 1.5) * Globals.SCALE
		var camera = %Me.get_node("Camera2D")
		camera.limit_right = world_size.x
		camera.limit_bottom = world_size.y
		for r in range(world_tile_size.y):
			var row = []
			for c in range(world_tile_size.x):
				row.push_back(null)
			$UI.grid.push_back(row)
		for building in data["world"]["buildings"]:
			var instance = buildings[building.kind].instantiate()
			instance.cell = Vector2(building.pos[0], building.pos[1])
			instance.health = building.health
			$UI.add_building_to_grid(instance)
			$Buildings.add_child(instance)
		$UI.gold = data["world"]["gold"]
		visible = true

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
					if action["skin"] == "Tower" || action["skin"] == "Arthur":
						sprite.offset.y -= 10.0
						var collision_shape_2d = entity.get_node("CollisionShape2D")
						collision_shape_2d.position.y -= 10.0
						collision_shape_2d.scale *= 2.0
					if action["skin"] == "Chest":
						$UI.show_notice("A chest has appeared!")
					if action["skin"] == "Arthur":
						$UI.show_notice("KING ARTHUR HAS RISEN!")
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
			if action.has("weapon"):
				entity.weapon_id = action.weapon
			entity.positions.push_back(PositionSnapshot.new(pos, action.get("aim", 0.0), time))
		elif type == "entitiesDeleted":
			for id in action["ids"]:
				if id == WebSocket.local_player_id:
					%Me.alive = false
					_exit_tree()
				elif entities.has(id):
					var entity = entities[id]
					if entity.enemy and action["gold"] > $UI.gold:
						var coin_particles = CoinParticles.instantiate()
						var cpu_particles_2d = coin_particles.get_node("CPUParticles2D")
						cpu_particles_2d.emitting = true
						cpu_particles_2d.finished.connect(coin_particles.queue_free)
						coin_particles.position = entity.position
						add_child(coin_particles)
						# play sound
					entity.queue_free()
					entities.erase(id)
			$UI.gold = action["gold"]
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
			if p && is_instance_valid(p):
				if action["weapon"] == "GrenadeLauncher":
					var shockwave = Shockwave.instantiate()
					shockwave.monitoring = false
					shockwave.position = parse_pos(action["pos"])
					shockwave.z_index = 1
					%Projectiles.add_child(shockwave)
				p.queue_free()
			remote_projectiles.erase(action["id"])
		elif type == "buildingCreated":
			var instance = buildings[action.kind].instantiate()
			instance.cell = Vector2(action.pos[0], action.pos[1])
			$UI.add_building_to_grid(instance)
			$Buildings.add_child(instance)
			$UI.gold = action.gold
		elif type == "buildingUpdated":
			if $UI.grid.is_empty():
				return # fixes the race condition of this message arriving before welcome
			var instance = $UI.grid[action.pos[1]][action.pos[0]]
			if action.has("health"):
				instance.health = action.health
				if instance.health == 0 and instance.name != "SwordStone":
					var tween = instance.create_tween()
					tween.tween_property(instance, 'modulate:a', 0.0, 0.2)
					tween.tween_callback(instance.queue_free)
					$UI.remove_building_from_grid(instance)
					# play sound
			if action.has("interest"):
				instance.card_set[0].description = "Current interest: %d." % action.interest
				if not action.has("gold") and not $UI/Cards.card_sets.is_empty() and $UI/Cards.card_sets[0] == instance.card_set:
					$UI/Cards.update_cards()
			if action.has("gold"):
				$UI.gold = action.gold
		elif type == "gunBought":
			if action.buyerId == WebSocket.local_player_id:
				%Me.weapon_id = action.weapon
				for card in Armory.card_set:
					if card.id == action.weapon:
						card.originalCost = card.cost
						card.cost = 0
						card.disabled = true
					else:
						card.erase("disabled")
			$UI.gold = action.gold
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
		if entity.positions.size() >= 2 and drawnTime >= entity.positions[1].time:
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
