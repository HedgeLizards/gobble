extends Control

const CARD_WIDTH = 168.0
const CARD_SEPARATION = 32.0
const UICard = preload('res://scenes/ui_card.tscn')

var card_sets = []
var on_clicks = []
var tween

func add_card_set(card_set, override, on_click):
	if override:
		card_sets.push_front(card_set)
		on_clicks.push_front(on_click)
	else:
		card_sets.push_back(card_set)
		on_clicks.push_back(on_click)
	
	if card_set == card_sets[0]:
		update_cards()
	
	if card_sets.size() == 1:
		show_cards()

func remove_card_set(card_set):
	var index = card_sets.find(card_set)
	
	card_sets.remove_at(index)
	on_clicks.remove_at(index)
	
	if card_sets.is_empty():
		hide_cards()
	elif index == 0:
		update_cards()

func update_cards():
	var card_count = card_sets[0].size()
	var children = get_children()
	var child_count = children.size()
	
	var screen_scale = DisplayServer.screen_get_scale()
	var half_total_width = (card_count * CARD_WIDTH + (card_count - 1) * CARD_SEPARATION) / 2.0 * screen_scale
	
	for i in max(card_count, child_count):
		if i >= card_count:
			children[i].queue_free()
			
			continue
		
		var ui_card
		
		if i < child_count:
			ui_card = children[i]
		else:
			ui_card = UICard.instantiate()
			
			ui_card.gui_input.connect(
				func(event):
					if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
						if on_clicks.is_empty() || ui_card.disabled:
							return
						
						on_clicks[0].call(i)
						
						$'../CardClick'.play()
			)
			
			add_child(ui_card)
		
		ui_card.position.x = i * (CARD_WIDTH + CARD_SEPARATION) * screen_scale - half_total_width
		
		var card = card_sets[0][i]
		
		ui_card.disabled = card.cost > get_parent().gold || card.has('disabled')
		
		ui_card.get_node('VBoxContainer/Cost/Label').text = str(card.cost)
		ui_card.get_node('VBoxContainer/Title').text = card.title
		ui_card.get_node('VBoxContainer/TextureRect').texture = card.texture
		ui_card.get_node('VBoxContainer/Description').text = card.description

func show_cards():
	$'../CardsToggle'.play()
	
	if tween != null:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'anchor_bottom', 0.75, 0.4)
	tween.parallel().tween_property(self, 'modulate:a', 1.0, 0.4)

func hide_cards():
	if tween != null:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'anchor_bottom', 1.0, 0.4)
	tween.parallel().tween_property(self, 'modulate:a', 0.0, 0.4)
	tween.tween_callback(
		func():
			for ui_card in get_children():
				ui_card.queue_free()
	)
