extends Node2D

@export var bgm: AudioStream
@export var beatmap_name: String
@export var note_prefab: PackedScene
@export var note_prefab_red: PackedScene
@export var note_prefab_yellow: PackedScene
@export var judgment_line_y: float = 563.0
@export var note_speed: float = 750.0
@export var music_duration: float = 60.0
@export var auto: bool = false


var lane_x = [144, 144+288, 144+288*2, 144+288*3]

var score: int = 0
var combo: int = 0

var judge_score = {
	"Perfect": 300,
	"Great": 200,
	"Good": 100,
	"Miss": 0
}

var note_timings = []
var active_notes: Array[Area2D] = []
var music_player: AudioStreamPlayer
var hp = 20

# ===================== 通用工具函数：加载并解析JSON文件 =====================
# 功能：读取文件路径 → 加载文本 → 解析JSON → 统一异常处理
# 参数：file_path - 文件完整路径（如 res://beatmap/test.json）
# 返回：解析成功返回JSON数据(Array/Dict)，失败返回 null
func load_file(file_path: String) -> Variant:
	# 1. 校验路径是否为空
	if not file_path:
		print("❌ 文件路径为空！")
		return null

	# 2. 打开并读取文件
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("❌ 文件打开失败：", file_path)
		return null

	# 3. 读取文本并关闭文件
	var file_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var err = json.parse(file_text)
	if err != OK:
		print("❌ JSON解析错误：", json.get_error_message(), " | 行号：", json.get_error_line())
		return null

	return json.data

func load_custom_beatmap() -> void:
	var beatmap_path: String = "res://beatmaps/" + beatmap_name + ".json"
	
	var beatmap_data = load_file(beatmap_path)
	
	if beatmap_data != null and beatmap_data is Array:
		note_timings = beatmap_data
		print("✅ 成功加载谱面：", beatmap_name, " | 音符数：", note_timings.size())
	else:
		print("▶ 切换为测试谱面")
		generate_test_note_timings()

func _ready() -> void:
	$hp.text = "20"
	if get_tree().has_meta("selected_song"):
		beatmap_name = get_tree().get_meta("selected_song")
	
	if beatmap_name == "":
		generate_test_note_timings()
	else:
		load_custom_beatmap()
	
	if bgm == null && (beatmap_name != ""):
		bgm = load("res://music/" + beatmap_name + ".mp3")
#		$PV.stream=load("res://pv/" + beatmap_name + ".ogv")
		$Background.texture=load("res://backgrounds/" + beatmap_name + ".png")
	
	music_player = AudioStreamPlayer.new()
	music_player.name = "BGM_Player"
	music_player.stream = bgm
	add_child(music_player)
	
	music_player.finished.connect(end_count)
	
	print("按空格键开始游戏 | 按键D/F/J/K击中音符")

func _spawn_notes_coroutine() -> void:
	var last = 0.0
	for note_data in note_timings:
		
		await get_tree().create_timer(note_data["time"]-last).timeout
		last = note_data["time"]
		if note_data.get("type"):
			spawn_note(note_data["time"], note_data["lane"], note_data["type"])
		else:
			spawn_note(note_data["time"], note_data["lane"], "blue")

func spawn_note(timing: float, lane: int, type: String) -> void:
	if not note_prefab:
		print("未赋值音符预制体！")
		return
	
	var note
	if type == "blue":
		note = note_prefab.instantiate() as Area2D
	else: if type == "red":
		note = note_prefab_red.instantiate() as Area2D
	elif type == "yellow":
		note = note_prefab_yellow.instantiate() as Area2D
	var fall_length = judgment_line_y + 100
	
	note.set("lane", lane)
	note.set("judge_time", timing + (fall_length / note_speed) - 1.8)  # 判定时间
	note.set("speed", note_speed)
	
	note.position = Vector2(lane_x[lane - 1], -100)
	
	add_child(note)
	active_notes.append(note)
	# note.physics_process.connect(_on_note_physics_process.bind(note))

func generate_test_note_timings() -> void:
	note_timings.clear()
	var t = 0.5
	while t < music_duration:
		var lane = randi() % 4 + 1
		note_timings.append({
			"time": t,
			"lane": lane
		})
		t += randf_range(0.3, 0.8)

var gaming: bool = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_start"):
		if !gaming :
			gaming = true
			start_game()
		else:
			print(active_notes)
			pass
			
	if event.is_action_pressed("D"):
		judge_note(1)
	elif event.is_action("D"):
		judge_yellow_note(1)
	
	if event.is_action_pressed("F"):
		judge_note(2)
	elif event.is_action("F"):
		judge_yellow_note(2)
	
	if event.is_action_pressed("J"):
		judge_note(3)
	elif event.is_action("J"):
		judge_yellow_note(3)
	
	if event.is_action_pressed("K"):
		judge_note(4)
	elif event.is_action("K"):
		judge_yellow_note(4)
	
	if event.is_action_pressed("XVN"):
		judge_slip()

func start_game() -> void:
	score = 0
	combo = 0
#	score_label.text = "Score: 0"
#	combo_label.text = "Combo: 0"
	for note in active_notes:
		note.queue_free()
	active_notes.clear()
	
	music_player.play()
	if($PV.stream):
		$PV.play()
		$Background.self_modulate=Color(128,128,128,0)
	_spawn_notes_coroutine()

func judge_note(index: int) -> void:
	
	var my_sprite = Sprite2D.new()
	
	my_sprite.texture = preload("res://click.png") 
	
	my_sprite.position = Vector2(lane_x[index-1], judgment_line_y)  # 屏幕中心位置
	
	add_child(my_sprite)
	
	get_tree().create_timer(0.1).timeout.connect(
		func() :
			var sp = my_sprite
			sp.visible = false
			remove_child(sp)
			sp.queue_free()
	)
	
	if index < 1 or index > 4:
		return
	
	var target_note: Area2D = null
	var min_diff = 99999
	
	for note in active_notes:
		if note.get("lane") != index:
			continue
		var diff = abs(note.position.y - judgment_line_y)
		if diff < min_diff:
			min_diff = diff
			target_note = note
	
	
	if not target_note:
		return
	if target_note.judge_hit():
		active_notes.erase(target_note)

func judge_yellow_note(index: int) -> void:
	if index < 1 or index > 4:
		return
	
	var target_note: Area2D = null
	var min_diff = 99999
	
	for note in active_notes:
		if note.get("lane") != index || note.get("type") != "yellow":
			continue
		var diff = abs(note.position.y - judgment_line_y)
		if diff < min_diff:
			min_diff = diff
			target_note = note
	
	
	if not target_note:
		return
	if target_note.judge_hit():
		active_notes.erase(target_note)

func judge_slip() -> void:
	
	for note in active_notes:
		if note.get("type") != "red":
			continue
		if note.slip():
			active_notes.erase(note)
	
var ap: bool = true
func update_score(judge_level: String) -> void:
	score += judge_score[judge_level]
	if judge_level == "Miss":
		hp -= 1
		$hp.text = str(hp)
		combo = 0
	else:
		combo += 1
	
	if judge_level != "Perfect":
		ap = false
	
	$Combo.text = "COMBO: " + str(combo)
	$Score.text = "SCOPE: " + str(score)
	$Result.text = judge_level
	$Timer.stop()
	$Timer.start(2.5)
	await $Timer.timeout
	$Result.text = ""

func end_count():
	if ap:
		$Result.text = "All Perfect"
	elif hp == 20:
		$Result.text = "Full Combo"
	else:
		$Result.text = str(score)
	pass
