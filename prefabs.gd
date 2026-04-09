extends Area2D

@export var speed: float = 500.0
@export var judgment_line_y = 563.0
var judge_time: float = 0.0
var is_judged: bool = false
var lane: int

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_judged:
		return # 已判定的音符不再处理
	
	# 1. 音符持续下落
	position.y += speed * delta
	
	# debug	
#	var diff = abs(position.y - 563)
#	if diff < 9:
#		get_parent().judge_note(lane)
	
	# 2. （可选）Miss判定：超出判定线过远则判定为Miss
	# 可从game.gd传递judgment_line_y，或直接写死（如600）
	
	if position.y > judgment_line_y + 100:
		is_judged = true
		# 通知主脚本更新Miss分数（可选）
		get_parent().active_notes.erase(self)
		get_parent().call("update_score", "Miss")
		queue_free()

# 外部调用：音符击中判定
func judge_hit() -> bool:
	if is_judged:
		return false
	
	# 计算判定偏差
	var diff = abs(position.y - 563)
	var result = "Miss"
	if diff < 9:
		result = "Perfect"
	elif diff < 27:
		result = "Great"
	elif diff < 81:
		result = "Good"
	
	# 通知主脚本更新分数
	if result == "Miss":
		return false
	
	is_judged = true
	get_parent().call("update_score", result)
	queue_free()
	return true
