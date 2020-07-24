extends VBoxContainer

onready var scoreText = get_node('ScoreContainer/Score')

func _input(event):
	if event.is_action_pressed("ui_accept"):
		SceneManager.goto_scene('Game')


func _ready():
	scoreText.text = String(ScoreManager.score)
