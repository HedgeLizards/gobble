extends PanelContainer

var disabled = false:
	set(value):
		if value == disabled:
			return
		
		disabled = value
		
		if disabled:
			mouse_default_cursor_shape = CURSOR_ARROW
			
			$VBoxContainer/Cost/Label.add_theme_color_override('font_color', Color.hex(0xe56f4bff))
		else:
			mouse_default_cursor_shape = CURSOR_POINTING_HAND
			
			$VBoxContainer/Cost/Label.remove_theme_color_override('font_color')
var base_position_y
var tween

func _ready():
	var screen_scale = DisplayServer.screen_get_scale()
	var stylebox = get_theme_stylebox('panel')
	
	stylebox.border_width_bottom *= screen_scale
	stylebox.corner_radius_top_left *= screen_scale
	stylebox.corner_radius_top_right *= screen_scale
	stylebox.corner_radius_bottom_left *= screen_scale
	stylebox.corner_radius_bottom_right *= screen_scale
	stylebox.content_margin_left *= screen_scale
	stylebox.content_margin_top *= screen_scale
	stylebox.content_margin_right *= screen_scale
	stylebox.content_margin_bottom *= screen_scale
	
	$VBoxContainer.add_theme_constant_override('separation',
		$VBoxContainer.get_theme_constant('separation') * screen_scale
	)
	
	$VBoxContainer/Cost.add_theme_constant_override('separation',
		$VBoxContainer/Cost.get_theme_constant('separation') * screen_scale
	)
	$VBoxContainer/Cost/TextureRect.custom_minimum_size *= screen_scale
	$VBoxContainer/Cost/Label.add_theme_font_size_override('font_size',
		$VBoxContainer/Cost/Label.get_theme_font_size('font_size') * screen_scale
	)
	
	$VBoxContainer/Title.add_theme_font_size_override('font_size',
		$VBoxContainer/Title.get_theme_font_size('font_size') * screen_scale
	)
	
	$VBoxContainer/TextureRect.custom_minimum_size *= screen_scale
	
	$VBoxContainer/Description.custom_minimum_size *= screen_scale
	$VBoxContainer/Description.add_theme_font_size_override('font_size',
		$VBoxContainer/Description.get_theme_font_size('font_size') * screen_scale
	)
	
	await get_tree().process_frame
	
	base_position_y = -size.y / 2.0

func _on_mouse_entered():
	if get_parent().card_sets.is_empty() || base_position_y == null:
		return
	
	if tween != null:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'position:y', base_position_y - 16.0 * DisplayServer.screen_get_scale(), 0.2)

func _on_mouse_exited():
	if get_parent().card_sets.is_empty():
		return
	
	if tween != null:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'position:y', base_position_y, 0.2)
