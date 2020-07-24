extends Node

const ROW_CLEAR_SCORE_TABLE = [40, 100, 300, 1200]

var lines_cleared: int = 0
var score: int = 0

func update_score(number_of_lines: int, level: int):
	lines_cleared += number_of_lines
	score += ROW_CLEAR_SCORE_TABLE[number_of_lines - 1] * level

func add_idle_score(level: int):
	score += level

func reset():
	lines_cleared = 0
	score = 0
