extends Node2D

onready var gameBoard = get_node('Board')
onready var scoreText = get_node('ScoreText')
onready var levelText = get_node('LevelText')

const LINES_REQUIRED_FOR_LEVEL_UP: int = 2
const STARTING_LEVEL: int = 1

var _level: int = STARTING_LEVEL

func _on_level_change(newLevel):
	print('level change:', newLevel)
	levelText.text = String(newLevel)
	_level = newLevel

func _on_rows_cleared(rows):
	ScoreManager.update_score(len(rows), _level)
	_on_score_updated()

	print('Total lines cleared: ', ScoreManager.lines_cleared)

	var newLevel = STARTING_LEVEL + ScoreManager.lines_cleared / LINES_REQUIRED_FOR_LEVEL_UP
	if (newLevel != _level):
		gameBoard.set_level(newLevel)

func _on_drop_tetromino():
	ScoreManager.add_idle_score(_level)
	_on_score_updated()

func _on_score_updated():
	scoreText.text = String(ScoreManager.score)

func _on_game_over():
	SceneManager.goto_scene('GameOver')

func _ready():
	ScoreManager.reset()
	gameBoard.connect('level_change', self, '_on_level_change')
	gameBoard.connect('clear_rows', self, '_on_rows_cleared')
	gameBoard.connect('drop_tetromino', self, '_on_drop_tetromino')
	gameBoard.connect('game_over', self, '_on_game_over')
	gameBoard.start_game(STARTING_LEVEL)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# TODO: Pause game
		# get_tree().set_input_as_handled()
		# emit_signal("pause")
		pass
	else:
		if event.is_action_pressed("drop"):
			# TODO: Fast drop
			print("drop fast")
		else:
			var move_left = event.is_action_pressed("ui_left", true)
			var move_right = event.is_action_pressed("ui_right", true)
			var move_down = event.is_action_pressed("ui_down", true)
			var rotate_ccw = event.is_action_pressed("rotate_ccw")
			var rotate_cw = event.is_action_pressed("rotate_cw")

			gameBoard.control_block(move_left, move_right, move_down, rotate_ccw, rotate_cw)
