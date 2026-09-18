extends Control
## M0 launch baseline; gameplay and the complete menu arrive in later milestones.


func _ready() -> void:
	$Center/Content/Quit.grab_focus()
	print("Blackwell M0 baseline ready")


func _on_quit_pressed() -> void:
	get_tree().quit()
