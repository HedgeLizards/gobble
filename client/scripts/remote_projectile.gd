extends Area2D

var speed: float
var distance: float
var is_enemy: bool
var id: String
var playerId
var damage: float
var kind: String

const kinds = {
	"bullet": {
		"sprite": preload("res://scenes/Projectiles/bullet.tscn")
	},
	"arrow": {
		"sprite": preload("res://scenes/Projectiles/arrow.tscn")
	},
	"sword": {
		"sprite": preload("res://scenes/Projectiles/sword.tscn")
	}
}

func _physics_process(delta):
	move_local_x(speed * delta * Globals.SCALE)
	distance -= speed * delta
	if distance < 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if is_enemy && body.has_method("is_me") and body.is_me() and body.is_alive():
		WebSocket.send({
			"type": "impactProjectile",
			"creatorId": playerId,
			"id": id,
			"impactedId": WebSocket.local_player_id,
			"pos": [position.x / Globals.SCALE, position.y / Globals.SCALE],
			"damage": damage,
			"kind": kind
		})
		# body.hit(damage)
		queue_free()

func set_kind(kind: String) -> void:
	self.kind = kind
	var sprite = kinds[kind].sprite.instantiate()
	add_child(sprite)