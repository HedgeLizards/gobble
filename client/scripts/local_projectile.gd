extends Area2D

const speed := 60.0 * Globals.SCALE
var distance := 256.0
var id: String
const damage := 5.0
const Shockwave = preload("res://scenes/shockwave.tscn")
var weapon_id

func _physics_process(delta):
	move_local_x(speed * delta)
	distance -= speed * delta
	if distance < 0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("is_enemy") and area.is_enemy():
		var impactedIds = []
		if weapon_id == "GrenadeLauncher":
			var shockwave = Shockwave.instantiate()
			shockwave.position = position
			shockwave.z_index = 1
			get_parent().add_child.call_deferred(shockwave)
			await get_tree().physics_frame
			await get_tree().physics_frame
			for area2 in shockwave.get_overlapping_areas():
				if area2.has_method("is_enemy") and area2.is_enemy():
					impactedIds.push_back(area2.id)
		else:
			impactedIds.push_back(area.id)
		WebSocket.send({
			"type": "impactProjectile",
			"creatorId": WebSocket.local_player_id,
			"id": id,
			"impactedIds": impactedIds,
			"pos": [position.x / Globals.SCALE, position.y / Globals.SCALE],
			"damage": damage,
			"weapon": weapon_id,
		})
		queue_free()
