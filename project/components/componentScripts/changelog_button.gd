extends Button
signal changelog_hover
signal changelog_out

var changelog_text : String
var changelog_tooltip := preload("res://components/changelog_tool_tip.tscn")

func setup(changelog: Array) -> void:
	self.text = changelog[0]
	self.changelog_text = changelog[1]
	
func create_tool_tip() -> void:
	if has_node("StoryLabel"):
		if has_node("changelog_tool_time_out"):
			$changelog_tool_time_out.stop()
		return
	var changelog_tooltip_instance = changelog_tooltip.instantiate()
	changelog_tooltip_instance.update_text(self.changelog_text)
	add_child(changelog_tooltip_instance)
	changelog_tooltip_instance.mouse_in.connect(_changelog_tool_tip_hover)
	changelog_tooltip_instance.mouse_out.connect(free_tool_tip)
	changelog_tooltip_instance.mouse_out.connect(_tool_tip_out)
	if has_node("ChangelogToolTip"):
		$ChangelogToolTip.show()

func _tool_tip_out() -> void:
	changelog_out.emit()

func _changelog_tool_tip_hover() -> void:
	changelog_hover.emit()
	if has_node("changelog_tool_time_out"):
		$changelog_tool_time_out.stop()

func free_tool_tip() -> void:
	for child in self.get_children():
		child.queue_free()
	#if has_node("ChangelogToolTip"):
		#$ChangelogToolTip.queue_free()
	#if has_node("changelog_tool_time_out"):
		#$changelog_tool_time_out.queue_free()

func start_free_tool_tip() -> void:
	if has_node("changelog_tool_time_out"):
		$changelog_tool_time_out.start(0.2)
		return
	var timer := Timer.new()
	timer.one_shot = true
	timer.name = "changelog_tool_time_out"
	timer.timeout.connect(free_tool_tip)
	self.add_child(timer)
	timer.start(0.2)

func _on_mouse_entered() -> void:
	create_tool_tip()


func _on_mouse_exited() -> void:
	start_free_tool_tip()
