extends Reference


const CONST = preload("res://CONST.gd")

var _empty_cells = []
var _attack_cells = []
var _defence_cells = []


func compute_turn(field, signum, inversions):
    
    _empty_cells.clear()
    _attack_cells.clear()
    _defence_cells.clear()
    
    # Cells of interest
    var opposignum = CONST.OPPOSITE[signum]
    var empty_cells = []
    var signum_cells = []
    var opposignum_cells = []
    var cell
    for row in range(CONST.SIZE):
        for col in range(CONST.SIZE):
            cell = {
                "col": col,
                "row": row
            }
            match field.get_cell(col, row):
                CONST.SIGNUM.EMPTY:
                    empty_cells.append(cell)
                signum:
                    signum_cells.append(cell)
                opposignum:
                    opposignum_cells.append(cell)
    
    # Examine empty cells
    var command
    var result
    var n
    while empty_cells:
        cell = empty_cells.pop_front()
        command = {
            "action": CONST.AI_ACTION_SPAWN,
            "col": cell.col,
            "row": cell.row
        }
        # Attack
        result = _examine_cell(field, cell, signum)
        if result.score >= CONST.SIZE - 1:
            _attack_cells.append(command)
        else:
            _empty_cells.append(command)
        # Defence
        result = _examine_cell(field, cell, opposignum)
        if result.score >= CONST.SIZE - 1:
            if inversions < 1:
                _defence_cells.append(command)
            else:
                match result.score:
                    result.col_score:
                        n = 0
                    result.row_score:
                        n = 1
                    result.dia0_score:
                        n = 2
                    result.dia1_score:
                        n = 3
                command["action"] = CONST.AI_ACTION_INVERT
                command["linetype"] = ["Col", "Row", "Dia", "Dia"][n]
                command["number"] = [cell.col, cell.row, 0, 1][n]
                _defence_cells.append(command)
    
    if inversions > 0:
        # Examine cells with signum
        while signum_cells:
            cell = signum_cells.pop_front()
            command = {
                "action": CONST.AI_ACTION_INVERT
            }
            # Defence only
            result = _examine_cell(field, cell, opposignum)
            if result.score >= CONST.SIZE - 1:
                match result.score:
                    result.col_score:
                        n = 0
                    result.row_score:
                        n = 1
                    result.dia0_score:
                        n = 2
                    result.dia1_score:
                        n = 3
                command["linetype"] = ["Col", "Row", "Dia", "Dia"][n]
                command["number"] = [cell.col, cell.row, 0, 1][n]
                _defence_cells.append(command)
        
        # Examine cells with opposite signum
        while opposignum_cells:
            cell = opposignum_cells.pop_front()
            command = {
                "action": CONST.AI_ACTION_INVERT
            }
            # Attack only
            result = _examine_cell(field, cell, signum)
            if result.score >= CONST.SIZE - 1:
                match result.score:
                    result.col_score:
                        n = 1
                    result.row_score:
                        n = 0
                    result.dia0_score:
                        n = 1
                    result.dia1_score:
                        n = 0
                command["linetype"] = ["Col", "Row"][n]
                command["number"] = [cell.col, cell.row][n]
                _attack_cells.append(command)
    
    # Result selection
    if _attack_cells:
        command = _attack_cells
    elif _defence_cells:
        command = _defence_cells
    else:
        command = _empty_cells
    
    if command:
        command = command[randi() % command.size()]
    
    return command


func _examine_cell(field, cell, signum):
    
    var result = {
        "score": 0,
        "col_score": 0,
        "row_score": 0,
        "dia0_score": 0,
        "dia1_score": 0
    }
    var col
    var row
    var dcol
    var drow
    var s
    
    # Lookup column
    for i in [0, 2]:
        col = cell.col
        row = cell.row
        drow = 1 - i
        row += drow
        s = field.get_cell(col, row)
        while s and (s == signum):
            result.col_score += 1
            row += drow
            s = field.get_cell(col, row)
    
    # Lookup row
    for i in [0, 2]:
        col = cell.col
        row = cell.row
        dcol = 1 - i
        col += dcol
        s = field.get_cell(col, row)
        while s and (s == signum):
            result.row_score += 1
            col += dcol
            s = field.get_cell(col, row)
    
    # Lookup diagonal "\"
    for i in [0, 2]:
        col = cell.col
        row = cell.row
        dcol = 1 - i
        drow = 1 - i
        col += dcol
        row += drow
        s = field.get_cell(col, row)
        while s and (s == signum):
            result.dia0_score += 1
            col += dcol
            row += drow
            s = field.get_cell(col, row)
    
    # Lookup diagonal "/"
    for i in [0, 2]:
        col = cell.col
        row = cell.row
        dcol = 1 - i
        drow = -1 + i
        col += dcol
        row += drow
        s = field.get_cell(col, row)
        while s and (s == signum):
            result.dia1_score += 1
            col += dcol
            row += drow
            s = field.get_cell(col, row)
    
    # Final result
    result.score = max(
        max(result.col_score, result.row_score), 
        max(result.dia0_score, result.dia1_score)
    )
    
    return result
