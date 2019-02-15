extends Node


const CONST = preload("res://CONST.gd")
const SAVE_PATH = "user://tic-tac-inverse.sav"


var difficulty = CONST.DIFFICULTY.LOW
var first_turn = CONST.SIGNUM.CIRCLE
var o_is_human = true
var x_is_human = false
var o_inversions = 1
var x_inversions = 1


func update_difficulty():
    Global.o_inversions = 1
    Global.x_inversions = 1
    var new_value
    match Global.difficulty:
        CONST.DIFFICULTY.LOW:
            new_value = 3
        CONST.DIFFICULTY.MEDIUM:
            new_value = 2
        CONST.DIFFICULTY.HIGH:
            new_value = 1
    if Global.o_is_human:
        Global.o_inversions = new_value
    if Global.x_is_human:
        Global.x_inversions = new_value
