extends Area2D

var speed: float
var distance: float
var is_enemy: bool
var id: String
var playerId
var damage: float
var weapon_id: String:
	set(value):
		weapon_id = value
		var path = "res://scenes/Projectiles/%s.tscn" % Weapons.weapons[weapon_id].projectile
		add_child(load(path).instantiate())

func _ready():
	var weapon = Weapons.weapons[weapon_id]
	
	speed = weapon.speed * Globals.SCALE
	distance = weapon.distance * Globals.SCALE
	damage = weapon.damage

func _physics_process(delta):
	move_local_x(speed * delta)
	distance -= speed * delta
	if distance < 0:
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	if is_enemy:
		body_entered.disconnect(_on_body_entered)
		WebSocket.send({
			"type": "impactProjectile",
			"creatorId": playerId,
			"id": id,
			"impactedIds": [WebSocket.local_player_id],
			"pos": [position.x / Globals.SCALE, position.y / Globals.SCALE],
			"damage": damage,
			"weapon": weapon_id
		})
		# body.hit(damage)
		queue_free()
