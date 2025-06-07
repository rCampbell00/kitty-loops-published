extends Resource
class_name BaseLevel
# Level, curr exp, exp to next - all that is used for the basic version
# Function for calculating next level cost
# Other ones can have a link to an action to check the next exp cost/boost/mods
var level := 0
var experience := 0
var exp_needed := 1

func calc_next_exp(_player: PlayerData) -> void:
	self.exp_needed = 1
# Add exp func

func add_exp(new_exp: int, player: PlayerData) -> bool:
	var did_level := false
	self.experience += new_exp
	while self.experience >= self.exp_needed:
		did_level = true
		self.experience -= self.exp_needed
		self.level += 1
		self.calc_next_exp(player)
	return did_level

# Reset func
func reset(player: PlayerData) -> void:
	self.experience = 0
	self.level = 0
	self.calc_next_exp(player)
# Getters
func get_level() -> int:
	return self.level

func get_exp() -> int:
	return self.experience
	
func get_exp_needed() -> int:
	return self.exp_needed

func set_level(new_level: int, new_exp: int, player: PlayerData) -> void:
	self.experience = new_exp
	self.level = new_level
	self.calc_next_exp(player)

func clear(player: PlayerData) -> void:
	self.set_level(0, 0, player)

func get_save_dict() -> Dictionary:
	return {"level": self.level, "exp": self.experience}

func load_save_dict(save_dict: Dictionary, player: PlayerData) -> void:
	var load_level := 0
	var load_exp := 0
	if (("level" in save_dict) and typeof(save_dict["level"]) == TYPE_FLOAT) and (("exp" in save_dict) and typeof(save_dict["exp"]) == TYPE_FLOAT):
		load_level = int(save_dict["level"])
		load_exp = int(save_dict["exp"])
	self.set_level(load_level, load_exp, player)
