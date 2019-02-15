extends Reference

const CONST = preload("res://CONST.gd")
const L = CONST.SIZE * CONST.SIZE

var _field = {}
var _free_cells
var _counter = {
    CONST.SIGNUM.EMPTY: 0,
    CONST.SIGNUM.CIRCLE: 0,
    CONST.SIGNUM.CROSS: 0
}


func _init():
    clear()


func clear():
    for row in range(CONST.SIZE):
        for col in range(CONST.SIZE):
            _field[Vector2(col, row)] = CONST.SIGNUM.EMPTY    
    _free_cells = L
    _reset_counter()


func _reset_counter():
    _counter[CONST.SIGNUM.EMPTY] = 0
    _counter[CONST.SIGNUM.CIRCLE] = 0
    _counter[CONST.SIGNUM.CROSS] = 0


func _get_max_signum():
    var result = {"signum": CONST.SIGNUM.EMPTY, "value": -1}
    for signum in _counter:
        if _counter[signum] > result.value:
            result.signum = signum
            result.value = _counter[signum]
    return result


func _is_signum_wins(result):
    return (result.signum != CONST.SIGNUM.EMPTY) and (result.value == CONST.SIZE)


func is_correct_index(col, row):
    return true if _field.has(Vector2(col, row)) else false


func get_cell(col, row):
    return _field[Vector2(col, row)] if is_correct_index(col, row) else null


func set_cell(col, row, signum):
    
    if !is_correct_index(col, row):
        return
    
    var index = Vector2(col, row)
    var old_signum = _field[index]
    _field[index] = signum
    
    if old_signum == CONST.SIGNUM.EMPTY:
        _free_cells -= 1        
    
    if signum == CONST.SIGNUM.EMPTY:
        _free_cells += 1


func invert_cell(col, row):
    
    if !is_correct_index(col, row):
        return
    
    var index = Vector2(col, row)
    var old_signum = _field[index]
    _field[index] = CONST.OPPOSITE[old_signum]


func is_possible_to_do_more_turns():
    
    return _free_cells > 0


func who_is_winner():
    
    var winner = {
        CONST.SIGNUM.CIRCLE: false,
        CONST.SIGNUM.CROSS: false
    }
    
    var result
    
    # Lookup rows (column by column)
    
    for row in range(CONST.SIZE):
        for col in range(CONST.SIZE):
            _counter[get_cell(col, row)] += 1
        result = _get_max_signum()
        if _is_signum_wins(result):
            winner[result.signum] = true
        _reset_counter()
    
    # Lookup columns (row by row)
    
    for col in range(CONST.SIZE):
        for row in range(CONST.SIZE):
            _counter[get_cell(col, row)] += 1
        result = _get_max_signum()
        if _is_signum_wins(result):
            winner[result.signum] = true
        _reset_counter()
    
    # Lookup diagonals
    
    for d in range(CONST.SIZE):
        _counter[get_cell(d, d)] += 1
    result = _get_max_signum()
    if _is_signum_wins(result):
        winner[result.signum] = true
    _reset_counter()
    
    for d in range(CONST.SIZE):
        _counter[get_cell(CONST.SIZE - d - 1, d)] += 1
    result = _get_max_signum()
    if _is_signum_wins(result):
        winner[result.signum] = true
    _reset_counter()
    
    # Compute answer
    result = CONST.SIGNUM.EMPTY
    if winner[CONST.SIGNUM.CIRCLE] and not winner[CONST.SIGNUM.CROSS]:
        result = CONST.SIGNUM.CIRCLE
    elif not winner[CONST.SIGNUM.CIRCLE] and winner[CONST.SIGNUM.CROSS]:
        result = CONST.SIGNUM.CROSS
    
    return result


func is_line_empty(coords):
    var result = true
    var c = coords.col
    var r = coords.row
    var s = get_cell(c, r)
    while s != null:
        if s != CONST.SIGNUM.EMPTY:
            result = false
            break
        c += coords.dcol
        r += coords.drow
        s = get_cell(c, r)
    return result
