extends MultipartDesc
class_name QualityDesc
## Extra information quality bar needs on top of usual multipart
# Names of the quality to use (up to a cap where it then starts adding +x)
# Bit of flavour text for the quality
# What the boost effect of completing the quality is (and what it is currently)

var quality_names := []
var quality_text := ""

func get_quality_name() -> String:
	var level : int = self.multipart_data.quality_level
	var name := ""
	if level >= len(quality_names):
		name = quality_names[-1]+"+"+str(level-len(quality_names)+1)
	else:
		name = quality_names[level]
	return name

func get_multipart_name() -> String:
	return self.get_quality_name()+" "+super()

func cal_qual_string(level: int) -> String:
	var boost : float = self.action_data.calc_quality_cost(level)
	var boost_text := ""
	if boost >= 10:
		boost_text = "%.0fx" % boost
	else:
		boost_text = "%.2fx" % boost
	return boost_text

func get_quality_boost() -> Array:
	var quality_arr := []
	quality_arr.append(self.cal_qual_string(self.multipart_data.quality_level))
	quality_arr.append(self.cal_qual_string(self.multipart_data.quality_level+1))
	return quality_arr
