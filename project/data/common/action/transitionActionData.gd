extends BaseActionData
class_name TransitionActionData

# Should be very similar to base action
# Main difference is on completion is needs to send player to a different town
# Conditional check is also a requirement for the town change
# Face judgement has multiple towns it can send you to - want a way to allow multiple choices

## Each town will need its own conditions
var town_changes := {}
var town_change_condition := {}

func swap_town(player: PlayerData, world: int, town: int) -> bool:
	if (world not in self.town_change_condition) or self.check_given_requirements(player, self.town_change_condition[world][town]):
		player.change_town(town, world)
		return true
	return false

func finish(player: PlayerData) -> void:
	super(player)
	for world in self.town_changes:
		for town in self.town_changes[world]:
			if self.swap_town(player, world, town): 
				return
