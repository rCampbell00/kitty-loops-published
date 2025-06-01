extends PanelContainer

func _ready() -> void:
	if get_parent() and not (get_parent() is Window):
		if (get_parent().global_position.x+size.x) >= (get_viewport_rect().size.x):
			position.x = get_parent().size.x - size.x + get_parent().global_position.x
		else:
			position.x = get_parent().global_position.x
		if get_parent().global_position.y > (get_viewport_rect().size.y/2):
			position.y = -2 -size.y + get_parent().global_position.y
		else:
			position.y = get_parent().size.y + 2 + get_parent().global_position.y

func update_text(text: String) -> void:
	$M/V/Text.text  = text
