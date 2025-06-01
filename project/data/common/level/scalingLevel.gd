extends BaseLevel
class_name ScalingLevel

var action_scaling_source: BaseActionData

func calc_next_exp(player: PlayerData) -> void:
	self.exp_needed = action_scaling_source.calc_action_level_cost(player, self.level)

func setup_action(player: PlayerData, action: BaseActionData) -> void:
	self.action_scaling_source = action
	self.calc_next_exp(player)
