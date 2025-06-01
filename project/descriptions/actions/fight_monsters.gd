extends MultipartDesc

func _init() -> void:
	self.action_name = "Fight Monsters"
	self.base_flavour_text = "Slowly, you're figuring out their patterns"
	self.base_effects_text = {"dynamic": ["Gives (Self Combat) * (1 + Main Stat/100) progress points per mana.", [], []], 
							"constants": ["Fight rotates between 3 types, Quick (Spd), Defensive (Str), and Offensive (Con)"], 
							"segment_resources": {"base": "Gives %d gold for every segment cleared.", "res_order": ["gold"]}}
	self.multipart_names = ["A Small Bunny", "A Scared Turtle", "A Starving Wolf"]
	self.segment_flavour = ["Track Movement", "Setup Trap", "Capture Prey", "Scan Target", "Find Weakpoint", "Pierce Defences", "Block Attacks", "Outmanoeuvre", "Parry Final Strike"]
	self.totals_name = "Killed"
