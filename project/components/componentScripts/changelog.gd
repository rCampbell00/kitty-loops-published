extends Label

var changelog_button := preload("res://components/changelog_button.tscn")
var height := 0

func _ready() -> void:
	self.text = LanguageValues.changelog_title
	for data in LanguageValues.changelog:
		var button := changelog_button.instantiate()
		button.setup(data)
		button.changelog_hover.connect(changelog_list_hovered)
		button.changelog_out.connect(start_hide_changelog)
		$ChangelogPanel/M/S/H.add_child(button)
	self.height = mini(len(LanguageValues.changelog)*25+10, 500)

func _on_mouse_entered() -> void:
	$ChangelogPanel.size.y = height
	$ChangelogPanel.show()

func hide_changelog() -> void:
	$ChangelogPanel.hide()
	if has_node("changelog_time_out"):
		$changelog_time_out.queue_free()

func start_hide_changelog() -> void:
	if has_node("changelog_time_out"):
		$changelog_time_out.start(0.2)
		return
	var timer := Timer.new()
	timer.one_shot = true
	timer.name = "changelog_time_out"
	timer.timeout.connect(hide_changelog)
	self.add_child(timer)
	timer.start(0.2)

func _on_mouse_exited() -> void:
	self.start_hide_changelog()

func changelog_list_hovered() -> void:
	if has_node("changelog_time_out"):
		$changelog_time_out.stop()


func _on_changelog_panel_mouse_entered() -> void:
	if has_node("changelog_time_out"):
		$changelog_time_out.stop()


func _on_changelog_panel_mouse_exited() -> void:
	self.start_hide_changelog()


func _on_changelog_panel_focus_entered() -> void:
	if has_node("changelog_time_out"):
		$changelog_time_out.stop()


func _on_changelog_panel_focus_exited() -> void:
	self.start_hide_changelog()
