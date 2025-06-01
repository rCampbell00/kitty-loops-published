extends Resource

var segments_progress : Array[int] = []
var segment_max : Array[int] = []
var segment_stats : Array[String] = []
var segments_cleared := 0

func setup(town_action: TownAction) -> void:
	for i in range(town_action.town_segments_count):
		segments_progress.append(0)
		segment_max.append(town_action.segment_max[i])
		segment_stats.append(town_action.segment_stats[i])

func reset() -> void:
	segments_cleared = 0
	for i in range(len(segments_progress)):
		segments_progress[i] = 0

func change_value(segment_index: int, value: int) -> void:
	if value < 0:
		self.remove_value(segment_index, value)
	else:
		self.add_value(segment_index, value)

func add_value(segment_index: int, value: int) -> void:
	if segments_progress[segment_index] >= segment_max[segment_index]:
		return
	segments_progress[segment_index] += value
	if segments_progress[segment_index] >= segment_max[segment_index]:
		segments_progress[segment_index] = segment_max[segment_index]
		segments_cleared += 1

func remove_value(segment_index: int, value: int) -> void:
	if segments_progress[segment_index] <= 0:
		return
	if segments_progress[segment_index] >= segment_max[segment_index]:
		segments_cleared -= 1
	segments_progress[segment_index] += value
	if segments_progress[segment_index] <= 0:
		segments_progress[segment_index] = 0

func get_segment_cleared(segment_index: int) -> bool:
	return segments_progress[segment_index] >= segment_max[segment_index]

func get_total_cleared() -> int:
	return segments_cleared
