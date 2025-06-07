extends Label

# Other possible options later
# Framerate of updating visuals
# Max number of actions for it to handle in a frame
# How often the game autosaves

var on_theme := false

func _ready() -> void:
	self.text = LanguageValues.option_title
	$OptionPanel/M/V/DiscordLink.text = LanguageValues.discord_text
	$OptionPanel/M/V/HBoxContainer/ThemeLabel.text = LanguageValues.theme_text
	$OptionPanel/M/V/ActionButton.text = LanguageValues.highlight_action_text
	
	for theme_name in LanguageValues.theme_names:
		$OptionPanel/M/V/HBoxContainer/ThemeButton.add_item(theme_name)
	make_option_pass_events($OptionPanel/M/V/HBoxContainer/ThemeButton)

func make_option_pass_events(option_button: OptionButton) -> void:
	var pm: PopupMenu = option_button.get_popup()
	#for i in pm.get_item_count():
	pm.about_to_popup.connect(hold_timer)
	pm.popup_hide.connect(cleared_theme)

func hold_timer() -> void:
	on_theme = true
	if has_node("option_time_out"):
		$option_time_out.stop()

func cleared_theme() -> void:
	on_theme = false
	self.start_hide_options()

func hide_options() -> void:
	$OptionPanel.hide()

func start_hide_options() -> void:
	if on_theme:
		return
	if has_node("option_time_out"):
		$option_time_out.start(0.2)
		return
	var timer := Timer.new()
	timer.one_shot = true
	timer.name = "option_time_out"
	timer.timeout.connect(hide_options)
	self.add_child(timer)
	timer.start(0.2)

func _on_mouse_entered() -> void:
	$OptionPanel.show()



func _on_mouse_exited() -> void:
	start_hide_options()

func _on_focus_entered() -> void:
	$OptionPanel.show()


func _on_focus_exited() -> void:
	start_hide_options()

func _on_option_panel_mouse_entered() -> void:
	if has_node("option_time_out"):
		$option_time_out.stop()


func _on_option_panel_mouse_exited() -> void:
	self.start_hide_options()


func _on_action_button_toggled(toggled_on: bool) -> void:
	Options.show_action_highlight = toggled_on
	ViewHandler.reset_action_highlights()
