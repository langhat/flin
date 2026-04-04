extends LineEdit

var songsMap = {
	"": ""
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_submitted.connect(_on_text_submitted)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_text_submitted(current : String) -> void:
	get_tree().set_meta("selected_song", songsMap[current])
	get_tree().change_scene_to_file("res://game.tscn")
