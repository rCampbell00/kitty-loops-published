extends ScalingLevel
class_name BoostLevel

var boosts := {}

func calc_boosts(player: PlayerData) -> void:
	self.boosts = self.action_scaling_source.calc_level_boost(player, self.level)	


func get_modifier(name: String) -> float:
	if name not in self.boosts:
		return 1.0
	return self.boosts[name]

func add_exp(new_exp: int, player: PlayerData) -> bool:
	var did_level = super(new_exp, player)
	if did_level:
		self.calc_boosts(player)
	return did_level

func reset(player: PlayerData) -> void:
	super(player)
	self.calc_boosts(player)

func set_level(new_level: int, new_exp: int, player: PlayerData) -> void:
	super(new_level, new_exp, player)
	self.calc_boosts(player)

func setup_action(player: PlayerData, action: BaseActionData) -> void:
	super(player, action)
	self.calc_boosts(player)
