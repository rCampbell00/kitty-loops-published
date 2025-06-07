extends Node

var show_action_highlight := true

func get_save_dict() -> Dictionary:
	var save_dict := {}
	save_dict["show_action_highlight"] = self.show_action_highlight
	return save_dict

func load_save_dict(save_dict: Dictionary) -> void:
	self.show_action_highlight = true
	if "show_action_highlight" in save_dict and typeof(save_dict["show_action_highlight"]) == TYPE_BOOL:
		self.show_action_highlight = save_dict["show_action_highlight"]
