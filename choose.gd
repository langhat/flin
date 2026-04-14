extends Node2D

@export var songsMap = {
	"Cherry Pop / 樱桃汽水 / チェリーポップ": "cherry_pop2",
	"转世林檎": "reincarnated_apple",
	"Lagtrain / 迟延列车 / 延误列车 / ラグトレイン": "lagtrain",
	"Yurail / 冲绳单轨 / ユレール" : "yurail",
	"Mousou Zei / 妄想税 / もうそうぜい" : "mousou_zei",
	"Nee Nee Nee. / 呐呐呐。 / ねぇねぇねぇ。" : "nee_nee_nee",
	"Little Match Reseller / 卖火柴的倒爷 / マッチ売りの転売ヤー" : "little_match_reseller",
	"Spot Late / 晚聚焦点" : "spot_late"
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
