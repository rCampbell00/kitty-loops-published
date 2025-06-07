extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.setup_connections(self)
	$World_Controller.setup_actions()
	EventBus.load_game()



#TODO - Setup a timer to save every x amount of seconds
