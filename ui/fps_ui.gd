extends Node
# shows the FPS, once every ~2s



var SECONDS_DURATION = 0.25
var fps_timer = Timer.new()
@onready var node_fps_textbox = $VBoxContainer/FPS



# VIRTUALS ###################################################################
func _ready() -> void:
	fps_timer.timeout.connect(_on_fps_timeout)
	add_child(fps_timer)
	fps_timer.start(SECONDS_DURATION)
	



# SIGNALS ####################################################################
func _on_fps_timeout():
	fps_timer.start(SECONDS_DURATION)
	node_fps_textbox.text = str(Engine.get_frames_per_second())
