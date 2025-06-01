extends Node

var all_actions := {
	"wander": preload("res://data/actionData/wander.gd").new(),
	"smash_pots": preload("res://data/actionData/smash_pots.gd").new(),
	"fight_monsters": preload("res://data/actionData/fight_monsters.gd").new(),
	"start_journey": preload("res://data/actionData/start_journey.gd").new()
}

var town_actions := [{Utility.Terra_Towns.BEGINNERSVILLE: preload("res://data/actionData/town_actions/zone_1.gd").new()},{},{}]

#Stores "skill name: action name" pairings to link skills to their key action
var skill_list = {}
var buff_list = {}
var boon_list = {}

var action_images := {}
var action_descs := {}

var action_to_world_town := {}
var multi_part_list = {}
#{skill name: [array of lootables]}
var skill_to_lootable_flags := {}
#TBD if these will be used
var buff_to_lootable_flags := {} 
var boon_to_lootable_flags := {}

func _init() -> void:
	self.setup_action_images()
	self.setup_action_links()

func handle_lootable_flags(data: LootableActionData) -> void:
	for flag in data.lootable_flags:
		if flag in skill_list:
			if flag not in skill_to_lootable_flags:
				skill_to_lootable_flags[flag] = {}
			skill_to_lootable_flags[flag][data.action_id] = data

func setup_action_links() -> void:
	for action in self.all_actions:
		var action_data : BaseActionData = self.all_actions[action]
		self.action_to_world_town[action_data.action_id] = [action_data.world_num, action_data.town_num]
		if action_data is LootableActionData:
			self.handle_lootable_flags(action_data)
		if action_data.main_skill != "":
			skill_list[action_data.main_skill] = action_data
		if action_data.main_buff != "":
			buff_list[action_data.main_buff] = action_data
		if action_data.main_boon != "":
			skill_list[action_data.main_boon] = action_data

func setup_action_images() -> void:
	for action in self.all_actions:
		var image := load("res://images/actionIcons/"+self.all_actions[action].action_id+".png")
		var story_load := load("res://descriptions/actions/"+self.all_actions[action].action_id+".gd")
		if not image:
			#TODO change to different image later to make it easier to identify
			image = preload("res://images/actionIcons/wander.png")
		if not story_load:
			story_load = preload("res://descriptions/actions/wander.gd")
		action_images[self.all_actions[action].action_id] = image
		action_descs[self.all_actions[action].action_id] = story_load.new()

# If custom creation of actions is implemented, can have these be updated by a file
var self_combat_func : Array[int] = []
var team_combat_func : Array[int] = []
#Could be skills, armour, weapon multiparts, boons
var combat_update_flags := []

func get_self_combat(player: PlayerData) -> int:
	return floor(CustomActionInterpreter.handle_function(self_combat_func, "self_combat", player))

func get_team_combat(player: PlayerData) -> int:
	return floor(CustomActionInterpreter.handle_function(team_combat_func, "team_combat", player, player.get_total_team_value()))
