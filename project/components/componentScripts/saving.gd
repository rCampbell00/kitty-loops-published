extends Label
var save_string := ""
var save_name := ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = LanguageValues.save_title
	$SavePanel/M/V/SaveManually.text = "  " + LanguageValues.save_manual_text + "  "
	$SavePanel/M/V/ListTitle.text = LanguageValues.save_subtitle_format % [LanguageValues.export_import_words[0], LanguageValues.export_import_words[1], LanguageValues.save_other_words[0]]
	$SavePanel/M/V/HList/Export.text = "  " + LanguageValues.export_import_words[0] + "  "
	$SavePanel/M/V/HList/Import.text = "  " + LanguageValues.export_import_words[1] + "  "
	$SavePanel/M/V/SaveTitle.text = LanguageValues.save_subtitle_format % [LanguageValues.export_import_words[0], LanguageValues.export_import_words[1], LanguageValues.save_other_words[1]]
	$SavePanel/M/V/HSave/Export.text = "  " + LanguageValues.export_import_words[0] + "  "
	$SavePanel/M/V/HSave/Import.text = "  " + LanguageValues.export_import_words[1] + "  "
	$SavePanel/M/V/Warning.text = LanguageValues.save_warning
	$SavePanel/M/V/HExport/Export.text = "  " + LanguageValues.export_import_words[0] + "  "
	$SavePanel/M/V/HExport/Import.text = "  " + LanguageValues.export_import_words[1] + "  "


func _on_list_export_pressed() -> void:
	$SavePanel/M/V/ListEdit.select_all()
	DisplayServer.clipboard_set($SavePanel/M/V/ListEdit.text)


func _on_save_export_pressed() -> void:
	self.save_string = EventBus.get_save_string()
	$SavePanel/M/V/SaveEdit.text = save_string
	$SavePanel/M/V/SaveEdit.select_all()
	DisplayServer.clipboard_set(save_string)

func _on_save_manually_pressed() -> void:
	EventBus.save()

func hide_save():
	$SavePanel.hide()

func start_hide_save() -> void:
	if has_node("save_time_out"):
		$save_time_out.start(0.2)
		return
	var timer := Timer.new()
	timer.one_shot = true
	timer.name = "save_time_out"
	timer.timeout.connect(hide_save)
	self.add_child(timer)
	timer.start(0.2)

func _on_mouse_entered() -> void:
	$SavePanel.show()


func _on_mouse_exited() -> void:
	start_hide_save()


func _on_focus_entered() -> void:
	$SavePanel.show()


func _on_focus_exited() -> void:
	start_hide_save()




func _on_save_import_pressed() -> void:
	var encoded_save : String = $SavePanel/M/V/SaveEdit.text
	EventBus.attempt_decode_save(encoded_save)


func _on_file_export_pressed() -> void:
	self.save_string = EventBus.get_save_string()
	self.save_name = "Kitty_Loops_"+LanguageValues.version_number.replace(".","_")+"_Loop_1.txt"
	var os :=  OS.get_name()
	if os == "Web":
		JavaScriptBridge.download_buffer(save_string.to_utf8_buffer(), save_name)
	else:
		$SaveDialogue.current_file = save_name
		$SaveDialogue.show()




func _on_save_dialogue_file_selected(path: String) -> void:
	var save_writer = FileAccess.open(path, FileAccess.WRITE)
	save_writer.store_line(self.save_string)


func _on_load_dialogue_file_selected(path: String) -> void:
	EventBus.load_game(path)
	


func _on_file_import_pressed() -> void:
	var os :=  OS.get_name()
	#if os == "Web":
		#JavaScriptBridge
	#else:
	#$SaveDialogue.current_file = save_name
	$LoadDialogue.show()


func _on_save_panel_mouse_entered() -> void:
	if has_node("save_time_out"):
		$save_time_out.stop()


func _on_save_panel_mouse_exited() -> void:
	self.start_hide_save()
