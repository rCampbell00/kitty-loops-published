extends Control

var buff_bar := preload("res://components/buff_bar.tscn")

func _ready() -> void:
	$BuffTitlePanel/BuffTitle.text = LanguageValues.buff_container_name
	for buff in Actions.buff_list:
		self.make_buff_bar(buff)

func make_buff_bar(buff_id: String) -> void:
	var new_buff_bar = buff_bar.instantiate()
	new_buff_bar.setup(buff_id)
	$BuffsContainer/M/S/V.add_child(new_buff_bar)

func update_buff(buff_id: String) -> void:
	self.show()
	$BuffsContainer/M/S/V.get_node(buff_id).update_values()

func reset_buffs() -> void:
	var visible_state := false
	for buff in Actions.buff_list:
		if not visible_state and MainPlayer.get_buff_level(buff) != 0:
			visible_state = true
		self.update_buff(buff)
		$BuffsContainer/M/S/V.get_node(buff).set_buff_cap(MainPlayer.chosen_buff_caps[buff])
	self.visible = visible_state
