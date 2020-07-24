class_name TetrominoManager

const TETROMINO_TYPES = [
	preload("res://scenes/tetrominos/i.tscn"),
	preload("res://scenes/tetrominos/j.tscn"),
	preload("res://scenes/tetrominos/l.tscn"),
	preload("res://scenes/tetrominos/o.tscn"),
	preload("res://scenes/tetrominos/s.tscn"),
	preload("res://scenes/tetrominos/t.tscn"),
	preload("res://scenes/tetrominos/z.tscn")
]
const NUMBER_OF_TETROMINO_TYPES = len(TETROMINO_TYPES)
const MAX_TETROMINOS_IN_QUEUE = 10

var _queue
var _current: Tetromino
var _next: Tetromino


func _init():
	self._queue = []


func _generate_queue():
	var _tetromino_index: int

	randomize()

	for _i in range(MAX_TETROMINOS_IN_QUEUE):
		_tetromino_index = randi() % NUMBER_OF_TETROMINO_TYPES
		self._queue.append(TETROMINO_TYPES[_tetromino_index])


# Gets a new tetromino from the queue
func get_tetromino() -> Tetromino:
	if self._queue.empty():
		_generate_queue()

	var _tetromino_type = self._queue.pop_front()
	self._current = _tetromino_type.instance()

	return self._current


# Gets the next tetromino in the queue
func get_next_tetromino() -> Tetromino:
	if self._queue.empty():
		_generate_queue()

	self._next = self._queue[0].instance()

	return self._next
