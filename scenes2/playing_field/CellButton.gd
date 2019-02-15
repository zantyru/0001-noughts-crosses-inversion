extends TextureButton


const CONST = preload("res://CONST.gd")

#export (int, 0, CONST.SIZE - 1) var column = 0
export (int, 0, 3) var column = 0
#export (int, 0, CONST.SIZE - 1) var row = 0
export (int, 0, 3) var row = 0

onready var _highlight = $Highlight
var _animation = {
    "spawn": {
        CONST.SIGNUM.EMPTY: "idle_empty",
        CONST.SIGNUM.CIRCLE: "spawn_circle",
        CONST.SIGNUM.CROSS: "spawn_cross"
    },
    "invert": {
        CONST.SIGNUM.EMPTY: "idle_empty",
        CONST.SIGNUM.CIRCLE: "invert_circle",
        CONST.SIGNUM.CROSS: "invert_cross"
    }
}


func _ready():
    light_off()


func spawn(signum):
    set_disabled(true)
    $Sign/Anim.play(_animation.spawn[signum])


func invert(signum):
    $Sign/Anim.play(_animation.invert[signum])


func light_on():
    _highlight.visible = true


func light_off():
    _highlight.visible = false


func reset():
    set_disabled(false)
    light_off()
    $Sign/Anim.play("idle_empty")