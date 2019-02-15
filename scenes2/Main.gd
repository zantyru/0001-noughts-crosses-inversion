extends Node2D


signal spawn_signum(col, row, signum)
signal invert_signum(col, row, signum)
signal light_on(col, row)
signal light_off(col, row)


const CONST = preload("res://CONST.gd")
const Field = preload("res://Field.gd")
const Player = preload("res://Player.gd")
const AISimple = preload("res://AISimple.gd")
const HumanSprite = preload("res://scenes2/_global/HumanSprite.tscn")
const ComputerSprite = preload("res://scenes2/_global/ComputerSprite.tscn")
const PlayingField = preload("res://scenes2/playing_field/PlayingField.tscn")
const Instruction = preload("res://scenes2/_global/Instructions.tscn")

onready var menu = $Menu
var playing_field
var inversion_buttons
onready var input_blocker = $HumanInputBlocker
onready var notify_escape = $Notifies/WouldYouLikeToDo
onready var notify_buttons = $Notifies/Buttons
onready var notifies = {
    CONST.SIGNUM.CIRCLE: $Notifies/PlayerOWins,
    CONST.SIGNUM.CROSS: $Notifies/PlayerXWins,
    CONST.SIGNUM.EMPTY: $Notifies/Tie
}
onready var turn_pointers_container = $TurnPointers
onready var turn_pointers = {
    CONST.SIGNUM.CIRCLE: $TurnPointers/PlayerOPointer,
    CONST.SIGNUM.CROSS: $TurnPointers/PlayerXPointer
}
onready var avatars = {
    CONST.SIGNUM.CIRCLE: $PlayerCircleAvatarAnchor,
    CONST.SIGNUM.CROSS: $PlayerCrossAvatarAnchor
}
onready var players_stats = {
    CONST.SIGNUM.CIRCLE: $PlayersStats/PlayerOStats,
    CONST.SIGNUM.CROSS: $PlayersStats/PlayerXStats
}
var players = {
    CONST.SIGNUM.CIRCLE: null,
    CONST.SIGNUM.CROSS: null
}
var current_signum
var field
var ai
var game_is_finished
var in_game


func _ready():
    print("%s: application started" % OS.get_ticks_msec())
    randomize()
    players[CONST.SIGNUM.CIRCLE] = Player.new()
    players[CONST.SIGNUM.CROSS] = Player.new()
    _update_avatars()
    start_menu()


func _unhandled_key_input(event):
    if not in_game:
        return
    if event.pressed and event.scancode == KEY_ESCAPE:
        notify_escape.visible = true
        get_tree().set_input_as_handled()


func start_menu():
    menu.visible = true
    in_game = false
    _remove_playing_field()
    _setup_interface_for_players(CONST.SIGNUM.EMPTY)
    Global.update_difficulty()
    _update_stats(Global.o_inversions, Global.x_inversions)
    _hide_notifies()


func start_game():
    
    menu.visible = false
    in_game = true
    _add_playing_field()
    _hide_notifies()
    input_blocker.visible = true
    game_is_finished = false
    field = Field.new()

    players[CONST.SIGNUM.CIRCLE].is_human = Global.o_is_human
    players[CONST.SIGNUM.CIRCLE].inversions = Global.o_inversions

    players[CONST.SIGNUM.CROSS].is_human = Global.x_is_human
    players[CONST.SIGNUM.CROSS].inversions = Global.x_inversions

    ai = AISimple.new()

    current_signum = Global.first_turn
    _update_stats(players[CONST.SIGNUM.CIRCLE].inversions, players[CONST.SIGNUM.CROSS].inversions)
    _setup_interface_for_players(current_signum)

    if !players[current_signum].is_human:
        do_ai()
    else:
        input_blocker.visible = false


func _remove_playing_field():
    inversion_buttons = null
    if playing_field != null:
        disconnect("spawn_signum", playing_field, "_on_spawn_signum")
        disconnect("invert_signum", playing_field, "_on_invert_signum")
        disconnect("light_on", playing_field, "_on_light_on")
        disconnect("light_off", playing_field, "_on_light_off")
        playing_field.disconnect("cell_pressed", self, "_on_cell_pressed")
        playing_field.disconnect("inversion_requested", self, "_on_inversion_requested")
        playing_field.disconnect("mouse_entered_to", self, "_on_mouse_entered_to")
        playing_field.disconnect("mouse_exited_from", self, "_on_mouse_exited_from")
        remove_child(playing_field)
        playing_field.queue_free()
        playing_field = null


func _add_playing_field():
    if playing_field != null:
        _remove_playing_field()
    playing_field = PlayingField.instance()
    add_child_below_node(get_node("_place_for_playing_field"), playing_field)
    playing_field.connect("cell_pressed", self, "_on_cell_pressed")
    playing_field.connect("inversion_requested", self, "_on_inversion_requested")
    playing_field.connect("mouse_entered_to", self, "_on_mouse_entered_to")
    playing_field.connect("mouse_exited_from", self, "_on_mouse_exited_from")
    connect("spawn_signum", playing_field, "_on_spawn_signum")
    connect("invert_signum", playing_field, "_on_invert_signum")
    connect("light_on", playing_field, "_on_light_on")
    connect("light_off", playing_field, "_on_light_off")
    inversion_buttons = playing_field.get_inversion_buttons_node()


func _setup_interface_for_players(signum):
    if signum == CONST.SIGNUM.EMPTY:
        turn_pointers_container.visible = false
        if inversion_buttons != null:
            inversion_buttons.set_disabled(true)
    elif signum != CONST.SIGNUM.EMPTY:
        var opposignum = CONST.OPPOSITE[signum]
        turn_pointers_container.visible = true
        turn_pointers[signum].visible = true
        turn_pointers[opposignum].visible = false
        var need_disabled = players[signum].inversions < 1
        if inversion_buttons != null:
            inversion_buttons.set_disabled(need_disabled)


func _hide_notifies():
    notify_escape.visible = false
    notifies[CONST.SIGNUM.CIRCLE].visible = false
    notifies[CONST.SIGNUM.CROSS].visible = false
    notifies[CONST.SIGNUM.EMPTY].visible = false
    notify_buttons.visible = false


func _update_avatars():
    var ava
    for child in avatars[CONST.SIGNUM.CIRCLE].get_children():
        child.queue_free()
    for child in avatars[CONST.SIGNUM.CROSS].get_children():
        child.queue_free()    
    ava = HumanSprite.instance() if Global.o_is_human else ComputerSprite.instance()
    avatars[CONST.SIGNUM.CIRCLE].add_child(ava)
    ava = HumanSprite.instance() if Global.x_is_human else ComputerSprite.instance()
    avatars[CONST.SIGNUM.CROSS].add_child(ava)


func _update_stats(o_inversions, x_inversions):
    players_stats[CONST.SIGNUM.CIRCLE].text = tr("KEY_STATS") % o_inversions
    players_stats[CONST.SIGNUM.CROSS].text = tr("KEY_STATS") % x_inversions


func next_turn():

    if game_is_finished:
        return

    var winner = field.who_is_winner()
    if (winner != CONST.SIGNUM.EMPTY) or !field.is_possible_to_do_more_turns():
        game_is_finished = true
        yield(get_tree().create_timer(1.4), "timeout")
        notifies[winner].visible = true
        notify_buttons.visible = true
        return

    current_signum = CONST.OPPOSITE[current_signum]
    _setup_interface_for_players(current_signum)
    
    if !players[current_signum].is_human:
        do_ai()
    else:
        input_blocker.visible = false


func do_ai():
    yield(get_tree().create_timer(0.6), "timeout")
    var command = ai.compute_turn(field, current_signum, players[current_signum].inversions)
    if command:
        match command.action:
            CONST.AI_ACTION_INVERT:
                _on_inversion_requested(command.linetype, command.number)
            CONST.AI_ACTION_SPAWN:
                _on_cell_pressed(command.col, command.row)
    else:
        print("AI fails")
        next_turn()


# Playing field: cells

func _on_cell_pressed(col, row):

    if game_is_finished:
        return

    input_blocker.visible = true
    
    emit_signal("spawn_signum", col, row, current_signum)
    field.set_cell(col, row, current_signum)
    next_turn()


# Playing field: invertion activation buttons

func _on_inversion_requested(linetype, number):
    
    var player = players[current_signum]
    if game_is_finished or player.inversions < 1:
        return
    
    input_blocker.visible = true
    
    var coords = CONST.parse_linetype_and_number(linetype, number)
    var s
    s = field.get_cell(coords.col, coords.row)
    while s != null:
        emit_signal("invert_signum", coords.col, coords.row, s)
        field.invert_cell(coords.col, coords.row)
        coords.col += coords.dcol
        coords.row += coords.drow
        s = field.get_cell(coords.col, coords.row)
    
    player.inversions -= 1
    _update_stats(players[CONST.SIGNUM.CIRCLE].inversions, players[CONST.SIGNUM.CROSS].inversions)
    next_turn()


# Playing field: highlight cells

func _on_mouse_entered_to(linetype, number):
    if game_is_finished or players[current_signum].inversions < 1:
        return
    var coords = CONST.parse_linetype_and_number(linetype, number)
    while (coords.col >= 0) and (coords.row >= 0) and (coords.col < CONST.SIZE) and (coords.row < CONST.SIZE):
        emit_signal("light_on", coords.col, coords.row)
        coords.col += coords.dcol
        coords.row += coords.drow


func _on_mouse_exited_from(linetype, number):
    var coords = CONST.parse_linetype_and_number(linetype, number)
    while (coords.col >= 0) and (coords.row >= 0) and (coords.col < CONST.SIZE) and (coords.row < CONST.SIZE):
        emit_signal("light_off", coords.col, coords.row)
        coords.col += coords.dcol
        coords.row += coords.drow


# Notify's buttons

func _on_PlayAgainButton_pressed():
    start_game()


func _on_BackToMenuButton_pressed():
    start_menu()


func _on_Resume_pressed():
    notify_escape.visible = false


# Main menu buttons

func _on_Menu_playing_requested():
    Global.save_settings(Global.get_settings_as_dictionary())
    start_game()


func _on_Menu_quitting_requested():
    get_tree().quit()


func _on_Menu_player_type_changed(signum, is_human):
    _update_avatars()
    _on_Menu_difficulty_changed()


func _on_Menu_difficulty_changed():
    Global.update_difficulty()
    _update_stats(Global.o_inversions, Global.x_inversions)


func _on_Menu_language_changed():
    _on_Menu_difficulty_changed()


func _on_Menu_instruction_requested():
    add_child_below_node(get_node("_place_for_instruction"), Instruction.instance())
