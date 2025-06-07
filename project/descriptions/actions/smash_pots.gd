extends LootableDesc

func _init() -> void:
	self.action_name = "Smash Pots"
	self.base_flavour_text = "They're just sitting there, unbroken, full of potential."
	self.base_effects_text = {"constants": ["Every 10 pots have mana in them.","Find 5 pots to check for every explored %."], "looted_resource": {"base": "Pots with mana in them have %d mana.", "res_order": ["mana"]}}
	self.lootable_name = "Pots"
	self.lootable_story_strings = [["loot_test", "Completed the looting test"], ["loot_test_2","Completed in loop test"]]
	self.lootable_story_conditions = [{"type": "total", "count": 2},{"type":"in_loop","count":1}]
