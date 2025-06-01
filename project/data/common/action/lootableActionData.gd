extends BaseActionData
class_name LootableActionData

# What is needed:
# name for the lootable on screen
var lootable_name := ""
# what you get for looting it (different to just completion)
## Multipliers for looted resources is resource name wih "_looted" after e.g. "gold_looted"
var looted_resources := {}
# Function to calculate how many lootables are avalable
## format is {town_progress: {}, skills: [], buffs: []}
## Town progress is prog*level + prog2*level
## skill multiplies the base gotten from town_progress
var lootable_total_multipliers := {}
# Ratio for how many are good lootables
var lootable_ratio := 10
# List of flags to say what skills/boons/etc will affect it
var lootable_flags := []

func add_lootable_resources(player: PlayerData) -> void:
	for res in looted_resources:
		player.add_resource(res, floor(looted_resources[res]*self.calculate_total_modifier(player, res+"_looted")))

func finish(player: PlayerData) -> void:
	super(player)
	if player.check_town_lootable(self.action_id):
		self.add_lootable_resources(player)

func calculate_total_lootables(player: PlayerData) -> int:
	var base_count := 0
	for prog in self.lootable_total_multipliers["town_progress"]:
		base_count += self.lootable_total_multipliers["town_progress"][prog]*player.get_town_progress(prog)
	var multiplier := 1.0
	if "skills" in self.lootable_total_multipliers:
		multiplier *= self.calc_skill_mult(player, self.lootable_total_multipliers["skills"])
	if "buffs" in self.lootable_total_multipliers:
		multiplier *= self.calc_buff_mult(player, self.lootable_total_multipliers["buffs"])
	return floor(base_count*multiplier)
	
