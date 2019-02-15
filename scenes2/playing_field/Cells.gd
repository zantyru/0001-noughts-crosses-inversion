extends GridContainer


signal cell_pressed(col, row)


var _cells = {}


func _ready():
    var children = get_children()
    for child in children:
        _cells[Vector2(child.column, child.row)] = child
        child.connect("pressed", self, "_on_pressed", [child.column, child.row])


func spawn(col, row, signum):
    _cells[Vector2(col, row)].spawn(signum)


func invert(col, row, signum):
    _cells[Vector2(col, row)].invert(signum)


func light_on(col, row):
    _cells[Vector2(col, row)].light_on()


func light_off(col, row):
    _cells[Vector2(col, row)].light_off()


func reset():
    var children = get_children()
    for child in children:
        child.reset()


# Signals forwarding

func _on_pressed(col, row):
    emit_signal("cell_pressed", col, row)
