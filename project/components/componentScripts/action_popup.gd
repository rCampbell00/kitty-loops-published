extends PanelContainer

func _ready() -> void:
	if get_parent():
		if (get_parent().global_position.x+size.x) >= (get_viewport_rect().size.x):
			position.x = get_parent().size.x - size.x + get_parent().global_position.x
		else:
			position.x = get_parent().global_position.x
		if get_parent().global_position.y > (get_viewport_rect().size.y/2):
			position.y = -2 -size.y + get_parent().global_position.y
		else:
			position.y = get_parent().size.y + 2 + get_parent().global_position.y

func update_flavour(text: String):
	$M/V/ActionFlavour.text = text
	
func update_effect(text: String):
	$M/V/ActionEffects.text = text
	
func update_stats(text: String):
	$M/V/ActionStats.text = text
