extends Control

var boon_bar := preload("res://components/boon_bar.tscn")

func _ready() -> void:
	$BoonTitlePanel/BoonTitle.text = LanguageValues.boon_container_name
	for boon in Actions.boon_list: #TODO make a check to add unique versions of the two boons
		self.make_boon_bar(boon)

func make_boon_bar(boon_id: String) -> void:
	var new_boon_bar = boon_bar.instantiate()
	new_boon_bar.setup(boon_id)
	$BoonsContainer/M/S/V.add_child(new_boon_bar)

func update_boon(boon_id: String) -> void:
	self.show()
	$BoonsContainer/M/S/V.get_node(boon_id).update_values()

func reset_boons() -> void:
	var visible_state := false
	for boon in Actions.boon_list:
		if not visible_state and MainPlayer.get_boon_level(boon) != 0:
			visible_state = true
		self.update_boon(boon)
	self.visible = visible_state
