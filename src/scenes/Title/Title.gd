extends VBoxContainer


func _input(event):
	if event.is_action_pressed("ui_accept"):
		SceneManager.goto_scene('Game')
