extends Node2D

# ===================== 导出配置（在编辑器中赋值） =====================
# 背景音乐（拖入音频文件，如mp3/wav）
@export var bgm: AudioStream
# 音符预制体（仅需Area2D+Sprite2D+CollisionShape2D）
@export var note_prefab: PackedScene
# 判定线Y坐标（与场景中视觉判定线一致）
@export var judgment_line_y: float = 563.0
# 音符下落速度（像素/秒）
@export var note_speed: float = 500.0
# 音乐总时长（秒，需与bgm时长一致）
@export var music_duration: float = 60.0

# ===================== 内部变量 =====================
# 轨道X坐标（4个轨道）
var lane_x = [144, 144+288, 144+288*2, 144+288*3]
# 分数/连击
var score: int = 0
var combo: int = 0
# 判定分数映射
var judge_score = {
	"Perfect": 300,
	"Great": 200,
	"Good": 100,
	"Miss": 0
}
# 音符时间轴（存储每个音符的生成时间+轨道）
var note_timings: Array[Dictionary] = []
# 活跃音符列表（场景中未判定的音符）
var active_notes: Array[Area2D] = []
# 音乐播放器节点（动态创建）
var music_player: AudioStreamPlayer
# UI节点（动态创建/编辑器赋值）
#var score_label: Label
#var combo_label: Label

# ===================== 初始化 =====================
func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "BGM_Player"
	music_player.stream = bgm
	add_child(music_player)
	# 5. 生成测试音符时间轴
	generate_test_note_timings()
	# 提示：按空格开始游戏
	print("按空格键开始游戏 | 按键D/F/J/K击中音符")

func _spawn_notes_coroutine() -> void:
	for note_data in note_timings:
		# 等待到音符生成时间
		await get_tree().create_timer(note_data["time"]).timeout
		spawn_note(note_data["time"], note_data["lane"])

func spawn_note(timing: float, lane: int) -> void:
	if not note_prefab:
		print("未赋值音符预制体！")
		return
	# 实例化音符
	var note = note_prefab.instantiate() as Area2D
	var fall_length = judgment_line_y + 100
	# 初始化音符属性
	note.set("lane", lane)          # 轨道
	note.set("judge_time", timing + (fall_length / note_speed) - 1.8)  # 判定时间
	note.set("speed", note_speed)   # 下落速度
	# 设置初始位置（轨道X + 屏幕顶部外Y）
	note.position = Vector2(lane_x[lane - 1], -100)
	# 添加到场景和活跃列表
	add_child(note)
	active_notes.append(note)
	# 绑定音符更新回调
	# note.physics_process.connect(_on_note_physics_process.bind(note))

# ===================== 音符时间轴生成 =====================
func generate_test_note_timings() -> void:
	note_timings.clear()
	var t = 0.5 # 首个音符延迟（秒）
	while t < music_duration:
		# 随机轨道（1-4）
		var lane = randi() % 4 + 1
		note_timings.append({
			"time": t,
			"lane": lane
		})
		# 随机节拍间隔（0.3-0.8秒）
		t += randf_range(0.3, 0.8)

# ===================== 音乐/游戏控制 =====================
func _input(event: InputEvent) -> void:
	# 按空格开始游戏
	if event.is_action_pressed("game_start"):
		start_game()
	# 检测轨道按键
	elif event.is_action_pressed("Z"):
		judge_note(1)
	elif event.is_action_pressed("C"):
		judge_note(2)
	elif event.is_action_pressed("B"):
		judge_note(3)
	elif event.is_action_pressed("M"):
		judge_note(4)

func start_game() -> void:
	# 重置分数/连击
	score = 0
	combo = 0
#	score_label.text = "Score: 0"
#	combo_label.text = "Combo: 0"
	# 清空残留音符
	for note in active_notes:
		note.queue_free()
	active_notes.clear()
	# 播放音乐
	music_player.play()
	_spawn_notes_coroutine()

func judge_note(index: int) -> void:
	# 1. 校验轨道索引有效性（1-4）
	if index < 1 or index > 4:
		return
	
	# 2. 找到当前轨道上「最接近判定时间」的活跃音符
	var target_note: Area2D = null
	var min_diff = 99999
	
	for note in active_notes:
		# 过滤同轨道的音符
		if note.get("lane") != index:
			continue
		var diff = abs(note.position.y - judgment_line_y)
		if diff < min_diff:
			min_diff = diff
			target_note = note
	
	
	# 3. 无对应轨道音符 → 无操作（按空键）
	if not target_note:
		return
	
	if target_note.judge_hit():
		active_notes.erase(target_note)
	
# ===================== 分数与连击更新 =====================
func update_score(judge_level: String) -> void:
	# 更新分数
	score += judge_score[judge_level]
	# 更新连击（Miss重置连击，其他判定增加连击）
	if judge_level == "Miss":
		combo = 0
	else:
		combo += 1
	# 更新UI显示
	$Combo.text = "COMBO: " + str(combo)
	$Score.text = "SCOPE: " + str(score)
	$Result.text = judge_level
	$Timer.stop()
	$Timer.start(2.5)
	await $Timer.timeout
	$Result.text = ""
	
