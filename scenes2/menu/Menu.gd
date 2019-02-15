extends Control


signal playing_requested()
signal quitting_requested()
signal difficulty_changed()
signal player_type_changed(signum, is_human)
signal language_changed()
signal instruction_requested()


const CONST = preload("res://CONST.gd")

onready var label_player_o_type = $VBoxContainer/HBoxContainer1/PlayerCircleTypeButton/Label
onready var label_player_x_type = $VBoxContainer/HBoxContainer1/PlayerCrossTypeButton/Label
onready var label_difficulty = $VBoxContainer/HBoxContainer2/DifficultyChoiceButton/Label
onready var label_first_turn = $VBoxContainer/HBoxContainer2/FirstTurnChoiceButton/Label
var difficuties = [
    "KEY_DIFFICULTY_LOW",
    "KEY_DIFFICULTY_MEDIUM",
    "KEY_DIFFICULTY_HIGH"
]
var locales = ["en", "ru"]
var locale_index = 0


func update_labels():
    label_player_o_type.text = tr("KEY_HUMAN") if Global.o_is_human else tr("KEY_COMPUTER")
    label_player_x_type.text = tr("KEY_HUMAN") if Global.x_is_human else tr("KEY_COMPUTER")
    label_difficulty.text = tr(difficuties[Global.difficulty])
    match Global.first_turn:
        CONST.SIGNUM.CIRCLE:
            label_first_turn.text = tr("KEY_CIRCLE")
        CONST.SIGNUM.CROSS:
            label_first_turn.text = tr("KEY_CROSS") 
    update()


func _ready():
    var locale = TranslationServer.get_locale()
    locale_index = locales.find(locale.substr(0, 2))
    if locale_index < 0:
        locale_index = 0
    TranslationServer.set_locale(locales[locale_index])
    update_labels()


func _on_PlayButton_pressed():
    emit_signal("playing_requested")


func _on_PlayerCircleTypeButton_pressed():
    Global.o_is_human = not Global.o_is_human
    update_labels()
    emit_signal("player_type_changed", CONST.SIGNUM.CIRCLE, Global.o_is_human)


func _on_PlayerCrossTypeButton_pressed():
    Global.x_is_human = not Global.x_is_human
    update_labels()
    emit_signal("player_type_changed", CONST.SIGNUM.CROSS, Global.x_is_human)


func _on_DifficultyChoiceButton_pressed():
    Global.difficulty = (Global.difficulty + 1) % difficuties.size()
    update_labels()
    emit_signal("difficulty_changed")


func _on_FirstTurnChoiceButton_pressed():
    Global.first_turn = CONST.OPPOSITE[Global.first_turn]
    update_labels()


func _on_LanguageButton_pressed():
    locale_index = (locale_index + 1) % locales.size()
    TranslationServer.set_locale(locales[locale_index])
    update_labels()
    emit_signal("language_changed")


func _on_QuitButton_pressed():
    emit_signal("quitting_requested")


func _on_ShowInstructionButton_pressed():
    emit_signal("instruction_requested")
