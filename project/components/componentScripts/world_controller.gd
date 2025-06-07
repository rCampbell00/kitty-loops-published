extends Control

var worlds := []

func _ready() -> void:
	worlds = [$TerraTowns]

func setup_actions() -> void:
	var terra_actions := {}
	var celestial_actions := {}
	var shadow_actions := {}
	var world_actions := [terra_actions, celestial_actions, shadow_actions]
	for action in Actions.all_actions:
		var action_data: BaseActionData = Actions.all_actions[action]
		var world : Dictionary = world_actions[action_data.world_num]
		if action_data.town_num not in world:
			world[action_data.town_num] = []
		world[Actions.all_actions[action].town_num].append(action_data)
	$TerraTowns.setup_actions(terra_actions, 0)

func update_world(world_index: int, town_index: int) -> void:
	worlds[world_index].reset_town_options(town_index)

func reset_world_view() -> void:
	for world in self.worlds:
		world.reset_world_view()
		
func reset_action_highlights() -> void:
	for world in self.worlds:
		world.reset_action_highlights()
