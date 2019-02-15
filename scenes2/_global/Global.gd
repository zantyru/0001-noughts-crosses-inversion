extends Node


const CONST = preload("res://CONST.gd")
const SAVE_PATH = "user://tic-tac-inverse.sav"


var difficulty
var first_turn
var o_is_human
var x_is_human
var o_inversions
var x_inversions


static func new_settings():
    var settings = {
        "difficulty": CONST.DIFFICULTY.LOW,
        "first_turn": CONST.SIGNUM.CIRCLE,
        "o_is_human": true,
        "x_is_human": false,
        "o_inversions": 1,
        "x_inversions": 1,
    }
    return settings


static func save_settings(settings):
    print("%s: saving settings" % OS.get_ticks_msec())
    var file = File.new()
    file.open(SAVE_PATH, File.WRITE)
    file.store_line(to_json(settings))
    file.close()


static func load_settings():
    var settings
    print("%s: loading settings" % OS.get_ticks_msec())
    var file = File.new()
    # Make sure a saved settings actually exists
    var settings_found = file.file_exists(SAVE_PATH)
    # If it does, open the file, read/parse its contents, and return them
    if settings_found:
        print("%s: existing save found; loading" % OS.get_ticks_msec())
        file.open(SAVE_PATH, File.READ)
        settings = parse_json(file.get_as_text())
    # If no saved settings exists, make a new one
    else:
        print("%s: no existing save found; making fresh settings" % OS.get_ticks_msec())
        settings = new_settings()
    return settings


func _ready():
    var settings = load_settings()
    difficulty = settings.difficulty
    first_turn = settings.first_turn
    o_is_human = settings.o_is_human
    x_is_human = settings.x_is_human
    o_inversions = settings.o_inversions
    x_inversions = settings.x_inversions


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


func get_settings_as_dictionary():
    var settings = {
        "difficulty": difficulty,
        "first_turn": first_turn,
        "o_is_human": o_is_human,
        "x_is_human": x_is_human,
        "o_inversions": o_inversions,
        "x_inversions": x_inversions,
    }
    return settings
