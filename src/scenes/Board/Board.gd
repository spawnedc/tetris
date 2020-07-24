extends Node2D

signal clear_rows(rows)
signal drop_tetromino
signal game_over
signal level_change

const MOVE_TIME: float = 0.2
const MAX_TETROMINO_TIME: float = 1.0
const DEFAULT_MOVE_VECTOR: Vector2 = Vector2(0, 1)
const GRACE_PERIOD_MODIFIER: float = 4.0

export (Vector2) var board_size = Vector2(10, 20)

var current_tetromino: Tetromino
var next_tetromino: Tetromino
var _level: int

var _tetromino_time: float
var _move_time: float
var _grace: bool
var _tetromino_manager := TetrominoManager.new()
var _game_over: bool


func set_level(level):
	if (level != _level):
		_level = level
		print('Level: ', level)
		emit_signal('level_change', level)

func start_game(level: int):
	print('starting game at level: ', level)
	set_level(level)
	_grace = false
	_tetromino_time = MAX_TETROMINO_TIME
	_move_time = MOVE_TIME
	_game_over = false


func _position_current_tetromino():
	var tetromino_rect = current_tetromino.get_rect()

	var board_middle = int(board_size.x / 2)
	var tetromino_middle = int(tetromino_rect.size.x / 2)

	var tetromino_pos = Vector2(board_middle - tetromino_middle, 1)
	current_tetromino.block_position = tetromino_pos


func _position_next_tetromino():
	var tetromino_rect = next_tetromino.get_rect()

	var board_middle = 17 # TODO: Dafuq?

	var tetromino_middle = int(tetromino_rect.size.x / 2)

	var tetromino_pos = Vector2(board_middle - tetromino_middle, 1)
	next_tetromino.block_position = tetromino_pos


func spawn_tetromino():
	current_tetromino = _tetromino_manager.get_tetromino()
	add_child(current_tetromino)
	_position_current_tetromino()

	_game_over = !_is_block_space_empty(current_tetromino.block_position,current_tetromino.block_rotation)

	if _game_over:
		emit_signal('game_over')

	if next_tetromino:
		remove_child(next_tetromino)

	next_tetromino = _tetromino_manager.get_next_tetromino()
	add_child(next_tetromino)
	_position_next_tetromino()


func _is_block_space_empty(pos, rot):
	var result = true

	for tile in current_tetromino.get_tiles(pos, rot):
		if $board_tiles.get_cellv(tile) != -1:
			result = false
			break

	return result


func move_tetromino(pos, rot):
	var new_pos = current_tetromino.block_position + pos
	var new_rot = current_tetromino.block_rotation + rot

	if _is_block_space_empty(new_pos, new_rot):
		current_tetromino.block_position = new_pos
		current_tetromino.block_rotation = new_rot


func control_block(move_left, move_right, move_down, rotate_ccw, rotate_cw):
	if (current_tetromino):
		var move = Vector2()
		var rotate = 0

		if move_left:
			move.x -= 1
		if move_right:
			move.x += 1
		if move_down:
			move.y += 1

		if rotate_ccw:
			rotate -= 1
		if rotate_cw:
			rotate += 1

		move_tetromino(move, rotate)

		_check_grace_period()

		if move_left or move_right or move_down:
			_move_time += MOVE_TIME


func _end_block():
	var tiles = current_tetromino.get_tiles()
	for t in tiles:
		$board_tiles.set_cellv(
			t + current_tetromino.block_position, current_tetromino.get_tile_type(t)
		)

	current_tetromino.queue_free()
	current_tetromino = null

	_check_completed_lines()


func _check_grace_period():
	var is_block_space_empty = _is_block_space_empty(
		current_tetromino.block_position + DEFAULT_MOVE_VECTOR, current_tetromino.block_rotation
	)

	if not is_block_space_empty:
		if _grace:
			_end_block()
			_grace = false
			_tetromino_time = 0
			print('END grace period')
		else:
			_grace = true
			_tetromino_time -= MAX_TETROMINO_TIME / GRACE_PERIOD_MODIFIER
			print('start grace period')


func drop_tetromino():
	move_tetromino(DEFAULT_MOVE_VECTOR, 0)
	_check_grace_period()


func _is_row_empty(row: int) -> bool:
	var _empty = true

	for _x in range(board_size.x, 0, -1):
		if $board_tiles.get_cell(_x, row) != -1:
			_empty = false
			break

	return _empty


func _is_row_complete(y: int) -> bool:
	var _complete = true

	for _x in range(board_size.x, 0, -1):
		if $board_tiles.get_cell(_x, y) == -1:
			_complete = false
			break

	return _complete


func _move_row(from: int, to: int):
	print('moving row ', from, ' to ', to)
	for _x in range(board_size.x, 0, -1):
		var cell = $board_tiles.get_cell(_x, from)
		$board_tiles.set_cell(_x, to, cell)
		# clear the original cell
		$board_tiles.set_cell(_x, from, -1)


func _clear_row(row: int):
	for _x in range(board_size.x, 0, -1):
		$board_tiles.set_cell(_x, row, -1)


func _check_completed_lines():
	var rows_need_clearing = []

	for _y in range(board_size.y, 0, -1):
		if _is_row_complete(_y) == true:
			rows_need_clearing.append(_y)

	if rows_need_clearing.empty() == false:
		_clear_lines(rows_need_clearing)
		emit_signal('clear_rows', rows_need_clearing)


func _clear_lines(lines: Array):
	print('****** CLEARING LINES ******')
	for line in lines:
		_clear_row(line)
	print('Lines cleared: ', lines)

	var lowest_empty_row = lines[0]

	for _y in range(lowest_empty_row, 0, -1):
		if _is_row_empty(_y) == false:
			_move_row(_y, lowest_empty_row)
			lowest_empty_row -= 1
			print('setting lowest empty row to ', lowest_empty_row)

	print('****** DONE ******')


func _process(delta):
	if not _game_over:
		if not current_tetromino:
			spawn_tetromino()

		_tetromino_time -= delta * _level

		if _tetromino_time <= 0:
			drop_tetromino()
			emit_signal('drop_tetromino')

			_tetromino_time += MAX_TETROMINO_TIME
