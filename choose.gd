extends Node2D

@export var songsMap = {
	"Cherry Pop / 樱桃汽水 / チェリーポップ": "cherry_pop2",
	"转世林檎": "reincarnated_apple",
	"Lagtrain / 迟延列车 / 延误列车 / ラグトレイン": "lagtrain",
	"Yurail / 冲绳单轨 / ユレール" : "yurail"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Into Songs".songsMap = songsMap
	var str = ""
	for each in songsMap:
		str += each + "\n"
	$Label.text = str
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
