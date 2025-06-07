extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.setup_connections(self)
	$World_Controller.setup_actions()
	EventBus.load_game()



#TODO - on loading a player save file, update visibility and all information relating to the player
# This inlcude if an action/exploration has been hidden or not
# And if the action has been completed or not prior (update ! and bool value)
