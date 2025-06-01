extends Resource

var completion_stories_incomplete := {}
var fail_stories_incomplete := {}
var lootable_stories_incomplete := {}
var multipart_stories_incomplete := {}
var skill_stories_incomplete := {}
var buff_stories_incomplete := {}
var boon_stories_incomplete := {}
var talent_stories_incomplete := {}

var completion_stories_complete := {}
var fail_stories_complete := {}
var lootable_stories_complete := {}
var multipart_stories_complete := {}
var skill_stories_complete := {}
var buff_stories_complete := {}
var boon_stories_complete := {}
var talent_stories_complete := {}
# On startup (and alter on load) - needs to create the list of each actions stories in a dictionary
func setup_story_tracking() -> void:
	for action in Actions.action_descs:
		var action_des : BaseActionDesc = Actions.action_descs[action]
		self.completion_stories_incomplete[action] = range(len(action_des.completion_story_conditions))
		self.fail_stories_incomplete[action] = range(len(action_des.fail_story_conditions))
		self.completion_stories_complete[action] = []
		self.fail_stories_complete[action] = []
		if action_des is LootableDesc:
			self.lootable_stories_incomplete[action] = range(len(action_des.lootable_story_conditions))
			self.lootable_stories_complete[action] = []
		if action_des is MultipartDesc:
			self.multipart_stories_incomplete[action] = range(len(action_des.multipart_story_conditions))
			self.multipart_stories_complete[action] = []
	for skill in EventBus.skill_subscriptions:
		for action in EventBus.skill_subscriptions[skill]:
			self.skill_stories_incomplete[action] = range(len(Actions.action_descs[action].skill_story_conditions))
			self.skill_stories_complete[action] = []
	for buff in EventBus.buff_subscriptions:
		for action in EventBus.buff_subscriptions[buff]:
			self.buff_stories_incomplete[action] = range(len(Actions.action_descs[action].buff_story_conditions))
			self.buff_stories_complete[action] = []
	for boon in EventBus.boon_subscriptions:
		for action in EventBus.boon_subscriptions[boon]:
			self.boon_stories_incomplete[action] = range(len(Actions.action_descs[action].boon_story_conditions))
			self.boon_stories_complete[action] = []
	for talent in EventBus.talent_subscriptions:
		for action in EventBus.talent_subscriptions[talent]:
			self.talent_stories_incomplete[action] = range(len(Actions.action_descs[action].talent_story_conditions))
			self.talent_stories_complete[action] = []
	
# For complete/fail: "type": then conditions
# Action completed - All below can be within "on complete", base one just has no conditions
#	This is just no condition
# Action with team members (might need to make it be based on x strength)
#	Stores strength required
# Action with resources - resource name, count, >=, <=
# Action with certain amount of a town's variable - town id, index of variable, count, >=/<=
# Action with % explored of an explore - action id, percentage >= to
# Total number of times action has been done - TODO
func handle_complete_fail_stories(story_conditions: Array ,incomplete_ids: Array) -> Array:
	var still_incomplete := []
	for id in incomplete_ids:
		var story_condition : Dictionary = story_conditions[id]
		match story_condition["type"]:
			"team_member":
				var team_power := MainPlayer.get_total_team_value()
				if team_power < story_condition["power"]:
					still_incomplete.append(id)
			"resource":
				var resource_count := MainPlayer.get_resource_count(story_condition["resource"])
				var check_count : int = story_condition["count"]
				var condition : String = story_condition["condition"]
				if condition == ">=" and resource_count < check_count:
					still_incomplete.append(id)
				elif condition == "<=" and resource_count > check_count:
					still_incomplete.append(id)
				elif condition == "==" and resource_count != check_count:
					still_incomplete.append(id)
			"town_variable":
				var resource_count := MainPlayer.get_town_value(story_condition["index"], story_condition["town_id"])
				var check_count : int = story_condition["count"]
				var condition : String = story_condition["condition"]
				if condition == ">=" and resource_count < check_count:
					still_incomplete.append(id)
				elif condition == "<=" and resource_count > check_count:
					still_incomplete.append(id)
				elif condition == "==" and resource_count != check_count:
					still_incomplete.append(id)
			"explore":
				var explore_level := MainPlayer.get_town_progress(story_condition["id"])
				if explore_level < story_condition["level"]:
					still_incomplete.append(id)
	return still_incomplete

func update_action_completion_stories(action_id: String) -> void:
	var incomplete_conditions : Array = self.completion_stories_incomplete[action_id]
	if incomplete_conditions == []:
		return
	var complete_conditions : Array = Actions.action_descs[action_id].completion_story_conditions
	var newly_incomplete := self.handle_complete_fail_stories(complete_conditions, incomplete_conditions)
	if len(newly_incomplete) != len(incomplete_conditions):
		for id in incomplete_conditions:
			if not (id in newly_incomplete):
				completion_stories_complete[action_id].append(id)
		completion_stories_incomplete[action_id] = newly_incomplete
		ViewHandler.request_update("new_story", {action_id: self.check_all_stories_complete(action_id)})
		var world_town = Actions.action_to_world_town[action_id]
		var town_data : BaseTownData = EventBus.town_index_to_node[world_town[0]][world_town[1]].town_data
		town_data.action_stories_not_read[action_id] = true
		
func update_action_fail_stories(action_id: String) -> void:
	var incomplete_conditions : Array = self.fail_stories_incomplete[action_id]
	if incomplete_conditions == []:
		return
	var complete_conditions : Array = Actions.action_descs[action_id].fail_stories_conditions
	var newly_incomplete := self.handle_complete_fail_stories(complete_conditions, incomplete_conditions)
	if len(newly_incomplete) != len(incomplete_conditions):
		for id in incomplete_conditions:
			if not (id in newly_incomplete):
				fail_stories_complete[action_id].append(id)
		fail_stories_incomplete[action_id] = newly_incomplete
		ViewHandler.request_update("new_story", {action_id: self.check_all_stories_complete(action_id)})
		var world_town = Actions.action_to_world_town[action_id]
		var town_data : BaseTownData = EventBus.town_index_to_node[world_town[0]][world_town[1]].town_data
		town_data.action_stories_not_read[action_id] = true

func handle_skill_stories(story_conditions: Array ,incomplete_ids: Array, skill_id: String) -> Array:
	var still_incomplete := []
	for id in incomplete_ids:
		var story_condition : Dictionary = story_conditions[id]
		if skill_id == story_condition["skill"]:
			var level := MainPlayer.get_skill_level(skill_id)
			if level < story_condition["level"]:
				still_incomplete.append(id)
	return still_incomplete

func handle_buff_stories(story_conditions: Array ,incomplete_ids: Array, buff_id: String) -> Array:
	var still_incomplete := []
	for id in incomplete_ids:
		var story_condition : Dictionary = story_conditions[id]
		if buff_id == story_condition["buff"]:
			var level := MainPlayer.get_buff_level(buff_id)
			if level < story_condition["level"]:
				still_incomplete.append(id)
	return still_incomplete

func handle_boon_stories(story_conditions: Array ,incomplete_ids: Array, boon_id: String) -> Array:
	var still_incomplete := []
	for id in incomplete_ids:
		var story_condition : Dictionary = story_conditions[id]
		if boon_id == story_condition["boon"]:
			var level := MainPlayer.get_boon_level(boon_id)
			if level < story_condition["level"]:
				still_incomplete.append(id)
	return still_incomplete

func handle_talent_stories(story_conditions: Array ,incomplete_ids: Array, talent_id: String) -> Array:
	var still_incomplete := []
	for id in incomplete_ids:
		var story_condition : Dictionary = story_conditions[id]
		if talent_id == story_condition["talent"]:
			var level := MainPlayer.get_talent_level(talent_id)
			if level < story_condition["level"]:
				still_incomplete.append(id)
	return still_incomplete

func update_skill_stories(skill_id: String) -> void:
	var actions_with_skill_flag : Array = EventBus.skill_subscriptions[skill_id]
	var update_dict := {}
	for action_id in actions_with_skill_flag:
		var incomplete_conditions : Array = self.skill_stories_incomplete[action_id]
		var skill_story_conditions : Array = Actions.action_descs[action_id].skill_story_conditions
		var new_incomplete_stories := self.handle_skill_stories(skill_story_conditions, incomplete_conditions, skill_id)
		if len(new_incomplete_stories) != len(incomplete_conditions):
			for id in incomplete_conditions:
				if not (id in new_incomplete_stories):
					skill_stories_complete[action_id].append(id)
			skill_stories_incomplete[action_id] = new_incomplete_stories
			var world_town = Actions.action_to_world_town[action_id]
			var town_data : BaseTownData = EventBus.town_index_to_node[world_town[0]][world_town[1]].town_data
			town_data.action_stories_not_read[action_id] = true
			update_dict[action_id] = self.check_all_stories_complete(action_id)
	ViewHandler.request_update("new_story", update_dict)

func update_buff_stories(buff_id: String) -> void:
	var actions_with_buff_flag : Array = EventBus.buff_subscriptions[buff_id]
	var update_dict := {}
	for action_id in actions_with_buff_flag:
		var incomplete_conditions : Array = self.buff_stories_incomplete[action_id]
		var buff_story_conditions : Array = Actions.action_descs[action_id].buff_story_conditions
		var new_incomplete_stories := self.handle_buff_stories(buff_story_conditions, incomplete_conditions, buff_id)
		if len(new_incomplete_stories) != len(incomplete_conditions):
			for id in incomplete_conditions:
				if not (id in new_incomplete_stories):
					buff_stories_complete[action_id].append(id)
			buff_stories_incomplete[action_id] = new_incomplete_stories
			var world_town = Actions.action_to_world_town[action_id]
			var town_data : BaseTownData = EventBus.town_index_to_node[world_town[0]][world_town[1]].town_data
			town_data.action_stories_not_read[action_id] = true
			update_dict[action_id] = self.check_all_stories_complete(action_id)
	ViewHandler.request_update("new_story", update_dict)

func update_boon_stories(boon_id: String) -> void:
	var actions_with_boon_flag : Array = EventBus.boon_subscriptions[boon_id]
	var update_dict := {}
	for action_id in actions_with_boon_flag:
		var incomplete_conditions : Array = self.boon_stories_incomplete[action_id]
		var boon_story_conditions : Array = Actions.action_descs[action_id].boon_story_conditions
		var new_incomplete_stories := self.handle_boon_stories(boon_story_conditions, incomplete_conditions, boon_id)
		if len(new_incomplete_stories) != len(incomplete_conditions):
			for id in incomplete_conditions:
				if not (id in new_incomplete_stories):
					boon_stories_complete[action_id].append(id)
			boon_stories_incomplete[action_id] = new_incomplete_stories
			var world_town = Actions.action_to_world_town[action_id]
			var town_data : BaseTownData = EventBus.town_index_to_node[world_town[0]][world_town[1]].town_data
			town_data.action_stories_not_read[action_id] = true
			update_dict[action_id] = self.check_all_stories_complete(action_id)
	ViewHandler.request_update("new_story", update_dict)

func update_talent_stories(talent_id: String) -> void:
	var actions_with_talent_flag : Array = EventBus.talent_subscriptions[talent_id]
	var update_dict := {}
	for action_id in actions_with_talent_flag:
		var incomplete_conditions : Array = self.talent_stories_incomplete[action_id]
		var talent_story_conditions : Array = Actions.action_descs[action_id].talent_story_conditions
		var new_incomplete_stories := self.handle_talent_stories(talent_story_conditions, incomplete_conditions, talent_id)
		if len(new_incomplete_stories) != len(incomplete_conditions):
			for id in incomplete_conditions:
				if not (id in new_incomplete_stories):
					talent_stories_complete[action_id].append(id)
			talent_stories_incomplete[action_id] = new_incomplete_stories
			var world_town = Actions.action_to_world_town[action_id]
			var town_data : BaseTownData = EventBus.town_index_to_node[world_town[0]][world_town[1]].town_data
			town_data.action_stories_not_read[action_id] = true
			update_dict[action_id] =  self.check_all_stories_complete(action_id)
	ViewHandler.request_update("new_story", update_dict)

func handle_explore_stories(story_conditions: Array, incomplete_ids: Array) -> Array:
	var still_incomplete := []
	for id in incomplete_ids:
		var story_condition : Dictionary = story_conditions[id]
		if story_condition["type"] == "explore":
			var explore_level := MainPlayer.get_town_progress(story_condition["id"])
			if explore_level < story_condition["level"]:
				still_incomplete.append(id)
		else:
			still_incomplete.append(id)
	return still_incomplete

func update_explore_action_stories(explore_id: String) -> void:
	var incomplete_conditions : Array = self.completion_stories_incomplete[explore_id]
	if incomplete_conditions == []:
		return
	var complete_conditions : Array = Actions.action_descs[explore_id].completion_story_conditions
	var newly_incomplete := self.handle_explore_stories(complete_conditions, incomplete_conditions)
	if len(newly_incomplete) != len(incomplete_conditions):
		for id in incomplete_conditions:
			if not (id in newly_incomplete):
				completion_stories_complete[explore_id].append(id)
		completion_stories_incomplete[explore_id] = newly_incomplete
		ViewHandler.request_update("new_story", {explore_id: self.check_all_stories_complete(explore_id)})
		var world_town = Actions.action_to_world_town[explore_id]
		var town_data : BaseTownData = EventBus.town_index_to_node[world_town[0]][world_town[1]].town_data
		town_data.action_stories_not_read[explore_id] = true

func handle_lootable_stories(story_conditions: Array, incomplete_ids: Array, action_id: String) -> Array:
	var still_incomplete := []
	for id in incomplete_ids:
		var story_condition : Dictionary = story_conditions[id]
		#{"check_new": true, "good": 0, "checked_good": 0, "total": 0, "checked": 0}
		match story_condition["type"]:
			"total":
				var lootable_data := MainPlayer.get_lootable_data(action_id)
				if lootable_data["good"] < story_condition["count"]:
					still_incomplete.append(id)
			"in_loop":
				var lootable_data := MainPlayer.get_lootable_data(action_id)
				if lootable_data["checked_good"] < story_condition["count"]:
					still_incomplete.append(id)
	return still_incomplete

func handle_multipart_stories(story_conditions: Array, incomplete_ids: Array, action_id: String) -> Array:
	var still_incomplete := []
	for id in incomplete_ids:
		var story_condition : Dictionary = story_conditions[id]
		match story_condition["type"]:
			"segment":
				var multipart_data := MainPlayer.get_multipart_data(action_id)
				if multipart_data.segments_cleared < story_condition["count"]:
					still_incomplete.append(id)
			"loop":
				var multipart_data := MainPlayer.get_multipart_data(action_id)
				if multipart_data.loops_cleared < story_condition["count"]:
					still_incomplete.append(id)
			"total": #TODO
				still_incomplete.append(id)
			"quality":
				var multipart_data := MainPlayer.get_multipart_data(action_id)
				if multipart_data.quality_level < story_condition["count"]:
					still_incomplete.append(id)
	return still_incomplete

func update_lootable_action_stories(action_id: String) -> void:
	var incomplete_conditions : Array = self.lootable_stories_incomplete[action_id]
	if incomplete_conditions == []:
		return
	var complete_conditions : Array = Actions.action_descs[action_id].lootable_story_conditions
	var newly_incomplete := self.handle_lootable_stories(complete_conditions, incomplete_conditions, action_id)
	if len(newly_incomplete) != len(incomplete_conditions):
		for id in incomplete_conditions:
			if not (id in newly_incomplete):
				lootable_stories_complete[action_id].append(id)
		lootable_stories_incomplete[action_id] = newly_incomplete
		ViewHandler.request_update("new_story", {action_id: self.check_all_stories_complete(action_id)})
		var world_town = Actions.action_to_world_town[action_id]
		var town_data : BaseTownData = EventBus.town_index_to_node[world_town[0]][world_town[1]].town_data
		town_data.action_stories_not_read[action_id] = true

func update_multipart_action_stories(action_id: String) -> void:
	var incomplete_conditions : Array = self.multipart_stories_incomplete[action_id]
	if incomplete_conditions == []:
		return
	var complete_conditions : Array = Actions.action_descs[action_id].multipart_story_conditions
	var newly_incomplete := self.handle_explore_stories(complete_conditions, incomplete_conditions)
	if len(newly_incomplete) != len(incomplete_conditions):
		for id in incomplete_conditions:
			if not (id in newly_incomplete):
				multipart_stories_complete[action_id].append(id)
		multipart_stories_incomplete[action_id] = newly_incomplete
		ViewHandler.request_update("new_story", {action_id: self.check_all_stories_complete(action_id)})
		var world_town = Actions.action_to_world_town[action_id]
		var town_data : BaseTownData = EventBus.town_index_to_node[world_town[0]][world_town[1]].town_data
		town_data.action_stories_not_read[action_id] = true

func get_incomplete_stories(action_id: String) -> Array:
	var incomplete_array := []
	incomplete_array.append(self.completion_stories_incomplete[action_id])
	if action_id in self.lootable_stories_incomplete:
		incomplete_array.append(self.lootable_stories_incomplete[action_id])
	if action_id in self.multipart_stories_incomplete:
		incomplete_array.append(self.multipart_stories_incomplete[action_id])
	incomplete_array.append(self.fail_stories_incomplete[action_id])
	if action_id in self.skill_stories_incomplete:
		incomplete_array.append(self.skill_stories_incomplete[action_id])
	else:
		incomplete_array.append([])
	if action_id in self.buff_stories_incomplete:
		incomplete_array.append(self.buff_stories_incomplete[action_id])
	else:
		incomplete_array.append([])
	if action_id in self.boon_stories_incomplete:
		incomplete_array.append(self.boon_stories_incomplete[action_id])
	else:
		incomplete_array.append([])
	if action_id in self.talent_stories_incomplete:
		incomplete_array.append(self.talent_stories_incomplete[action_id])
	else:
		incomplete_array.append([])
	return incomplete_array

func check_all_stories_complete(action_id: String) -> bool:
	var checks := [completion_stories_incomplete, fail_stories_incomplete, lootable_stories_incomplete,
					multipart_stories_incomplete, skill_stories_incomplete, buff_stories_incomplete,
					boon_stories_incomplete, talent_stories_incomplete]
	for check in checks:
		if action_id in check:
			if check[action_id] != []:
				return false
	return true

##Warning: This save has an issue if you add new stories in between the original set of stories
# As it uses the index rather than a unique ID, using a unique ID would require converting all the stories to use a dictionary
# With an ordering included if they are supposed to be in a specific order 
func get_save_dict() -> Dictionary:
	var save_dict := {}
	save_dict["completion_stories"] = self.completion_stories_complete
	save_dict["fail_stories"] = self.fail_stories_complete
	save_dict["lootable_stories"] = self.lootable_stories_complete
	save_dict["multipart_stories"] = self.multipart_stories_complete
	save_dict["skill_stories"] = self.skill_stories_complete
	save_dict["buff_stories"] = self.buff_stories_complete
	save_dict["boon_stories"] = self.boon_stories_complete
	save_dict["talent_stories"] = self.talent_stories_complete
	return save_dict

func handle_load_complete_fail_stories(save_dict: Dictionary) -> void:
	for action in Actions.action_descs:
		var action_des : BaseActionDesc = Actions.action_descs[action]
		self.completion_stories_complete[action] = []
		self.fail_stories_complete[action] = []
		if not (action in save_dict["completion_stories"]):
			self.completion_stories_incomplete[action] = range(len(action_des.completion_story_conditions))
			self.fail_stories_incomplete[action] = range(len(action_des.fail_story_conditions))
		else:
			self.completion_stories_incomplete[action] = []
			self.fail_stories_incomplete[action] = []
			#Have to do this as the json stores it as a float
			for id in save_dict["completion_stories"][action]:
				self.completion_stories_complete[action].append(int(id))
			#Have to go through each id from the conditions, in case there are more than can be told from the save data
			for id in range(len(action_des.completion_story_conditions)):
				if not (id in self.completion_stories_complete[action]):
					self.completion_stories_incomplete[action].append(id)
			for id in save_dict["fail_stories"][action]:
				self.fail_stories_complete[action].append(int(id))
			for id in range(len(action_des.fail_story_conditions)):
				if not (id in self.fail_stories_complete[action]):
					self.fail_stories_incomplete[action].append(id)
		if action_des is LootableDesc:
			self.lootable_stories_complete[action] = []
			if not (action in save_dict["lootable_stories"]):
				self.lootable_stories_incomplete[action] = range(len(action_des.lootable_story_conditions))
			else:
				self.lootable_stories_incomplete[action] = []
				for id in save_dict["lootable_stories"][action]:
					self.lootable_stories_complete[action].append(int(id))
				for id in range(len(action_des.lootable_story_conditions)):
					if not (id in self.lootable_stories_complete[action]):
						self.lootable_stories_incomplete[action].append(id)
		if action_des is MultipartDesc:
			self.multipart_stories_complete[action] = []
			if not (action in save_dict["multipart_stories"]):
				self.multipart_stories_incomplete[action] = range(len(action_des.multipart_story_conditions))
			else:
				self.multipart_stories_incomplete[action] = []
				for id in save_dict["multipart_stories"][action]:
					self.multipart_stories_complete[action].append(int(id))
				for id in range(len(action_des.multipart_story_conditions)):
					if not (id in self.multipart_stories_complete[action]):
						self.multipart_stories_incomplete[action].append(id)

func handle_load_skill_stories(save_dict: Dictionary) -> void:
	for action in self.skill_stories_complete.keys():
		var action_des : BaseActionDesc = Actions.action_descs[action]
		self.skill_stories_complete[action] = []
		if not (action in save_dict["skill_stories"]):
			self.skill_stories_incomplete[action] = range(len(action_des.skill_story_conditions))
		else:
			self.skill_stories_incomplete[action] = []
			for id in save_dict["skill_stories"][action]:
				self.skill_stories_complete[action].append(int(id))
			for id in range(len(action_des.skill_story_conditions)):
				if not (id in self.skill_stories_complete[action]):
					self.skill_stories_incomplete[action].append(id)

func handle_load_buff_stories(save_dict: Dictionary) -> void:
	for action in self.buff_stories_complete.keys():
		var action_des : BaseActionDesc = Actions.action_descs[action]
		self.buff_stories_complete[action] = []
		if not (action in save_dict["buff_stories"]):
			self.buff_stories_incomplete[action] = range(len(action_des.buff_story_conditions))
		else:
			self.buff_stories_incomplete[action] = []
			for id in save_dict["buff_stories"][action]:
				self.buff_stories_complete[action].append(int(id))
			for id in range(len(action_des.buff_story_conditions)):
				if not (id in self.buff_stories_complete[action]):
					self.buff_stories_incomplete[action].append(id)

func handle_load_boon_stories(save_dict: Dictionary) -> void:
	for action in self.boon_stories_complete.keys():
		var action_des : BaseActionDesc = Actions.action_descs[action]
		self.boon_stories_complete[action] = []
		if not (action in save_dict["boon_stories"]):
			self.boon_stories_incomplete[action] = range(len(action_des.boon_story_conditions))
		else:
			self.boon_stories_incomplete[action] = []
			for id in save_dict["boon_stories"][action]:
				self.boon_stories_complete[action].append(int(id))
			for id in range(len(action_des.boon_story_conditions)):
				if not (id in self.boon_stories_complete[action]):
					self.boon_stories_incomplete[action].append(id)

func handle_load_talent_stories(save_dict: Dictionary) -> void:
	for action in self.talent_stories_complete.keys():
		var action_des : BaseActionDesc = Actions.action_descs[action]
		self.talent_stories_complete[action] = []
		if not (action in save_dict["talent_stories"]):
			self.talent_stories_incomplete[action] = range(len(action_des.talent_story_conditions))
		else:
			self.talent_stories_incomplete[action] = []
			for id in save_dict["talent_stories"][action]:
				self.talent_stories_complete[action].append(int(id))
			for id in range(len(action_des.talent_story_conditions)):
				if not (id in self.talent_stories_complete[action]):
					self.talent_stories_incomplete[action].append(id)

#Going to be expensive to reload every single story
#Need to find a better way to store which stories were complete to simplify these
#without adding to the cost during run of the game
func load_save_dict(save_dict: Dictionary) -> void:
	if (typeof(save_dict["completion_stories"]) != TYPE_DICTIONARY or 
		typeof(save_dict["fail_stories"]) != TYPE_DICTIONARY or 
		typeof(save_dict["lootable_stories"]) != TYPE_DICTIONARY or 
		typeof(save_dict["multipart_stories"]) != TYPE_DICTIONARY or 
		typeof(save_dict["skill_stories"]) != TYPE_DICTIONARY or 
		typeof(save_dict["buff_stories"]) != TYPE_DICTIONARY or 
		typeof(save_dict["boon_stories"]) != TYPE_DICTIONARY or 
		typeof(save_dict["talent_stories"]) != TYPE_DICTIONARY):
		return
	self.handle_load_complete_fail_stories(save_dict)
	self.handle_load_skill_stories(save_dict)
	self.handle_load_buff_stories(save_dict)
	self.handle_load_boon_stories(save_dict)
	self.handle_load_talent_stories(save_dict)
