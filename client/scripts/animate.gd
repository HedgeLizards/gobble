extends Sprite2D

@export var wobble_speed = 15.0
@export var wobble_amplitude = 2.0

var wobble_phase = 0.0

@onready var base_offset_y = offset.y

func animate(position, previous_position, delta):
	var standstill = position.is_equal_approx(previous_position)
	
	if standstill && is_zero_approx(wobble_phase):
		return
	
	var next_wobble_phase = fmod(wobble_phase + delta * wobble_speed, TAU)
	
	if standstill && (wobble_phase >= PI) != (next_wobble_phase >= PI):
		next_wobble_phase = 0.0
	
	wobble_phase = next_wobble_phase
	
	offset.y = base_offset_y - sin(wobble_phase) * wobble_amplitude
	
	if !is_equal_approx(position.x, previous_position.x):
		flip_h = (position.x < previous_position.x)
