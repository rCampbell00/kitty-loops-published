extends PanelContainer
signal mouse_out
signal mouse_in

func _ready() -> void:
	if get_parent():
		position.x = get_parent().size.x - size.x + get_parent().global_position.x
		position.y = -2 -size.y + get_parent().global_position.y

func set_story_text(text: String) -> void:
	$M/StoryText.text = text


func _on_mouse_entered() -> void:
	mouse_in.emit()

func _on_mouse_exited() -> void:
	mouse_out.emit()
