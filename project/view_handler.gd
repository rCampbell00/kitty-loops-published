extends Node

#TODO add code in to update story as well - make call to the story code
var events := {
	## Update the progress bar for the skills, update action text which use these, update unlock for skills which need these
	## Also need to update lootables that are affected
	"skill_increase": {}, #TODO
	"buff_increase": {}, #TODO
	"boon_increase": {}, #TODO
	## Update progress bar
	"town_progress_increase": {},
	## Update the given value within the town
	"town_multipart_increase": {},
	"town_lootable_collected": {},
	"update_town": {},
	"update_resource": {}, #TODO
	"update_team_members": {}, #TODO
	"update_soul_stones": {}, #TODO
	## Update info in the given town, also tell town controller to update its arrows
	"update_action_highlight": {}, #TODO
	"update_story_highlight": {}, #TODO
	## Update the town/world controller and make a request to update action visibility
	"update_town_visibility": {},
	"update_world_visibility": {}, #TODO
	"update_town_action": {},
	"remove_alert": {},
	"new_story": {}
}


func _process(_delta: float) -> void:
	for event in self.events:
		self.call(event, self.events[event])
		self.events[event] = {}

func request_update(update_type: String, update_info: Dictionary) -> void:
	self.events[update_type].merge(update_info)

func update_actions(action_list: Array) -> void:
	for action in action_list:
		var indexes = Actions.action_to_world_town[action]
		EventBus.town_index_to_node[indexes[0]][indexes[1]].update_action(action)
		# Needs to update actions story
		

func skill_increase(update_info: Dictionary) -> void:
	for skill in update_info:
		# Call view update on skill bar
		if update_info[skill]:
			if skill in Actions.combat_update_flags:
				pass
			# Update skills story
			self.update_actions(EventBus.skill_subscriptions[skill])

func buff_increase(update_info: Dictionary) -> void:
	for buff in update_info:
		# Call view update on buff bar
		if update_info[buff]:
			if buff in Actions.combat_update_flags:
				pass
			# Update buff story
			self.update_actions(EventBus.buff_subscriptions[buff])

func boon_increase(update_info: Dictionary) -> void:
	for boon in update_info:
		# Call view update on boon bar
		if update_info[boon]:
			if boon in Actions.combat_update_flags:
				pass
			# Update boon story
			self.update_actions(EventBus.boon_subscriptions[boon])

func town_lootable_collected(update_info: Dictionary) -> void:
	for action in update_info.keys():
		var indexes = Actions.action_to_world_town[action]
		EventBus.town_index_to_node[indexes[0]][indexes[1]].update_lootable(action)
		#Story code for this has to be separate as it has a variety of conditions - call from driver?

func town_progress_increase(update_info: Dictionary) -> void:
	for action in update_info.keys():
		var indexes = Actions.action_to_world_town[action]
		EventBus.town_index_to_node[indexes[0]][indexes[1]].update_explore(action)
		#If true - town leveled so call story checks

func update_town(update_info: Dictionary) -> void:
	for world_town in update_info.keys():
		if world_town == 1:
			EventBus.town_index_to_node[world_town / 100][world_town % 100].update_town()


func town_multipart_increase(update_info: Dictionary) -> void:
	for action in update_info.keys():
		var indexes = Actions.action_to_world_town[action]
		if update_info[action]:
			EventBus.town_index_to_node[indexes[0]][indexes[1]].reset_multipart(action)
		else:
			EventBus.town_index_to_node[indexes[0]][indexes[1]].update_multipart(action)

# Remember to check if self/team combat needs to be updated
func update_resource(update_info: Dictionary) -> void:
	pass

func update_team_members(update_info: Dictionary) -> void:
	pass # Remember to update team_combat too

func update_soul_stones(update_info: Dictionary) -> void:
	pass

func update_action_highlight(update_info: Dictionary) -> void:
	pass

func update_story_highlight(update_info: Dictionary) -> void:
	pass

func update_world_visibility(update_info: Dictionary) -> void:
	pass

func update_town_action(update_info: Dictionary) -> void:
	for world_town in update_info:
		EventBus.town_index_to_node[world_town / 100][world_town % 100].update_town_action()
		

func update_town_visibility(update_info: Dictionary) -> void:
	for world in update_info:
		self.world_controller.update_world(world, update_info[world])
		self.update_town({world*100+update_info[world]: true})

func remove_alert(update_info: Dictionary) -> void:
	for action in update_info:
		var indexes = Actions.action_to_world_town[action]
		EventBus.town_index_to_node[indexes[0]][indexes[1]].remove_action_highlight(action)

func new_story(update_info: Dictionary) -> void:
	for action in update_info:
		var indexes = Actions.action_to_world_town[action]
		EventBus.town_index_to_node[indexes[0]][indexes[1]].add_story_highlight(action, update_info[action])

func reset_view() -> void:
	#Has to go through and reset all towns, stats/skill/boon containers, what worlds and towns are shown
	#Action story colours
	#! marks on action and their stories
	#towns/worlds visible (but keep on town 1)
	#Loadout on action list
	EventBus.world_controller.reset_world_view()
