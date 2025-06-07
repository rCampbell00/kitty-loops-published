extends Control

var skill_bar := preload("res://components/skillBar.tscn")

func _ready() -> void:
	$SkillTitlePanel/SkillTitle.text = LanguageValues.skill_container_name
	$SkillsContainer/M/S/V/SelfCombatStat/SelfCombatLabel.text = LanguageValues.skill_combate_names[0]
	$SkillsContainer/M/S/V/TeamCombatStat/TeamCombatLabel.text = LanguageValues.skill_combate_names[1]
	for skill in Actions.skill_list:
		self.make_skill_bar(skill)

func make_skill_bar(skill_id: String) -> void:
	var new_skill_bar = skill_bar.instantiate()
	new_skill_bar.setup(skill_id)
	$SkillsContainer/M/S/V.add_child(new_skill_bar)

func update_skill(skill_id: String) -> void:
	self.show()
	$SkillsContainer/M/S/V.get_node(skill_id).update_values()

func update_combat() -> void:
	var self_combat := MainPlayer.get_skill_level("self_combat")
	$SkillsContainer/M/S/V/SelfCombatStat/SelfCombatValue.text = Utility.numberToSuffix(self_combat)
	$SkillsContainer/M/S/V/SelfCombatStat.visible = self_combat != 0
	var team_combat := MainPlayer.get_skill_level("team_combat")
	$SkillsContainer/M/S/V/TeamCombatStat/TeamCombatValue.text = Utility.numberToSuffix(team_combat)
	$SkillsContainer/M/S/V/TeamCombatStat.visible = team_combat != 0

func reset_skills() -> void:
	var visible_state := false
	self.update_combat()
	for skill in Actions.skill_list:
		if not visible_state and MainPlayer.get_skill_level(skill) != 0:
			visible_state = true
		self.update_skill(skill)
	self.visible = visible_state
