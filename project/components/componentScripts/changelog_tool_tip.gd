extends PanelContainer
signal mouse_in
signal mouse_out

func _ready() -> void:
	if get_parent() and not (get_parent() is Window):
		position.x = get_parent().global_position.x + get_parent().size.x + 10
		if get_parent().global_position.y > (get_viewport_rect().size.y/2):
			position.y = get_parent().global_position.y + get_parent().size.y - size.y 
		else:
			position.y = get_parent().global_position.y
	self.size.y = mini(500, $M/S/Text.size.y+10)

func update_text(text: String) -> void:
	$M/S/Text.text  = text


func _on_mouse_entered() -> void:
	mouse_in.emit()


func _on_mouse_exited() -> void:
	mouse_out.emit()


func _on_focus_entered() -> void:
	mouse_in.emit()


func _on_focus_exited() -> void:
	mouse_out.emit()
