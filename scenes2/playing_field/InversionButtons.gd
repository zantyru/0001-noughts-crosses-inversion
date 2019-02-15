extends Control


signal inversion_requested(linetype, number)
signal mouse_entered_to(linetype, number)
signal mouse_exited_from(linetype, number)


func _ready():
    var children = get_children()
    for child in children:
        child.connect("pressed", self, "_on_inversion_requested", [child.linetype, child.number])
        child.connect("mouse_entered", self, "_on_mouse_entered_to_child", [child.linetype, child.number])
        child.connect("mouse_exited", self, "_on_mouse_exited_from_child", [child.linetype, child.number])


func set_disabled(value):
    var children = get_children()
    for child in children:
        child.disabled = value


# Signals forwarding

func _on_inversion_requested(linetype, number):
    emit_signal("inversion_requested", linetype, number)


func _on_mouse_entered_to_child(linetype, number):
    emit_signal("mouse_entered_to", linetype, number)


func _on_mouse_exited_from_child(linetype, number):
    emit_signal("mouse_exited_from", linetype, number)