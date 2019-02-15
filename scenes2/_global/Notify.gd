tool
extends Control


export (String) var text setget set_text
onready var _label = $Label


func _ready():
    if text == null:
        text = ""

func _draw():
    _label.text = tr(text)
    
func set_text(value):
    text = value
    if Engine.editor_hint:
        update()
