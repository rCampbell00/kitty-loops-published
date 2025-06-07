extends Resource

func save_game() -> void:
	var save_file := FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_data := self.create_save_file()
	save_file.store_line(save_data)

func export_save_string() -> String:
	var save_data := self.create_save_file()
	var base_64_save := Marshalls.utf8_to_base64(save_data)
	return base_64_save

# Version number and name
# Time of save (for offline)
# Stories not complete
# Totals - #TODO
# Options - #TODO
# Loadouts (and loadout currently on)- #TODO
# Tutorials seen - #TODO
# Set buff caps - #TODO
# Within the player:	
	# Player talent
	# Player skills, buffs, boons
	# Soul stones
	# Towns and worlds unlocked
#	Save each town which includes:
		#Town/world identifier
		#Explore progress (level, exp) of each explore
		#Lootable check_new, good, total, checked
		#Which actions have been completed
		#Which stories have not been read
		#Explorations which have been hidden
		#Actions which have been hidden
func create_save_file() -> String:
	var save_data := {}
	save_data["version"] = LanguageValues.version_number
	save_data["time"] = Time.get_unix_time_from_system()
	save_data["complete_stories"] = EventBus.get_story_save_dict()
	save_data["options"] = Options.get_save_dict()
	save_data["player"] = MainPlayer.get_save_dict()
	var  save_string := JSON.stringify(save_data)
	return save_string

func import_save_from_string(encoded_save: String) -> void:
	var save_string := Marshalls.base64_to_utf8(encoded_save)
	load_game(save_string, "" ,true)


#things that will need to be reset and updated on load visually:
#All actions,
#All town explores
#All skill/stat/buff/boon things
#Action story colours
#! marks on action and their stories
#towns/worlds visible (but keep on town 1)
#Loadout on action list
func load_game(save_string : String = "", load_path : String = "", load_string : bool = false) -> void:
	if (save_string == "" and load_string) or not FileAccess.file_exists("user://savegame.save"):
		handle_load({})
		return
	var to_parse : String
	if load_string:
		to_parse = save_string
	else:
		if load_path == "":
			load_path = "user://savegame.save"
		var save_file = FileAccess.open(load_path, FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			to_parse = save_file.get_line()
	var json = JSON.new()
	# Check if there is any error while parsing the JSON string, skip in case of failure.
	var parse_result = json.parse(to_parse)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", to_parse, " at line ", json.get_error_line())
		handle_load({})
	var save_data : Dictionary = json.data
	handle_load(save_data)

func handle_load(save_data : Dictionary) -> void:
	if "options" in save_data:
		Options.load_save_dict(save_data["options"])
	else:
		Options.load_save_dict({})
	if "complete_stories" in save_data:
		EventBus.load_story_save_dict(save_data["complete_stories"])
	else:
		EventBus.load_story_save_dict({})
	if "player" in save_data:
		MainPlayer.load_save_dict(save_data["player"])
	else:
		MainPlayer.load_save_dict({})
	ViewHandler.reset_view()
