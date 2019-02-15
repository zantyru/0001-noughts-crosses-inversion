extends Node


enum SIGNUM {EMPTY, CIRCLE, CROSS}

const OPPOSITE = {
    SIGNUM.EMPTY: SIGNUM.EMPTY,
    SIGNUM.CIRCLE: SIGNUM.CROSS,
    SIGNUM.CROSS: SIGNUM.CIRCLE
}

const SIZE = 4

const AI_ACTION_INVERT = "invert"
const AI_ACTION_SPAWN = "spawn"

const LINETYPE_COL = "Col"
const LINETYPE_ROW = "Row"
const LINETYPE_DIA = "Dia"

enum DIFFICULTY {LOW, MEDIUM, HIGH}


static func parse_linetype_and_number(linetype, number):
    var result = {
        "col": 0,
        "row": 0,
        "dcol": 0,
        "drow": 0
    }
    match linetype:
        LINETYPE_COL:
            result.col = number
            result.row = 0
            result.dcol = 0
            result.drow = 1
        LINETYPE_ROW:
            result.col = 0
            result.row = number
            result.dcol = 1
            result.drow = 0
        LINETYPE_DIA:
            result.col = 0 if number == 0 else SIZE - 1
            result.row = 0
            result.dcol = 1 if number == 0 else -1
            result.drow = 1
    return result