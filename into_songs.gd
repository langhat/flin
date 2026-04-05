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

func check_contains(arg1: String, arg2: String) -> bool:
	var processed_arg1 = arg1.replace(" ", "").to_lower()
	var processed_arg2 = arg2.replace(" ", "").to_lower()
	return processed_arg1.contains(processed_arg2)


func _on_text_submitted(current : String) -> void:
	for each in songsMap:
		if check_contains(each, current):
			get_tree().set_meta("selected_song", songsMap[each])
			get_tree().change_scene_to_file("res://game.tscn")
