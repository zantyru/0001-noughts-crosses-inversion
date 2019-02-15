extends CenterContainer


signal cell_pressed(col, row)
signal inversion_requested(linetype, number)
signal mouse_entered_to(linetype, number)
signal mouse_exited_from(linetype, number)


onready var _cells = $Cells
onready var _inversion_buttons = $InversionButtons


func get_inversion_buttons_node():
    return _inversion_buttons


# Signals forwarding

func _on_Cells_cell_pressed(col, row):
    emit_signal("cell_pressed", col, row)


func _on_InversionButtons_inversion_requested(linetype, number):
    emit_signal("inversion_requested", linetype, number)


func _on_InversionButtons_mouse_entered_to(linetype, number):
    emit_signal("mouse_entered_to", linetype, number)


func _on_InversionButtons_mouse_exited_from(linetype, number):
    emit_signal("mouse_exited_from", linetype, number)


# Callback functions for incoming signals

func _on_spawn_signum(col, row, signum):
    _cells.spawn(col, row, signum)


func _on_invert_signum(col, row, signum):
    _cells.invert(col, row, signum)


func _on_light_on(col, row):
    _cells.light_on(col, row)


func _on_light_off(col, row):
    _cells.light_off(col, row)
