extends Spatial

var rng : RandomNumberGenerator

onready var fpCam: Camera = $Player/Camera
onready var tpCam: Camera = $Player/WorldCamera/Camera
onready var enemyScene = load("res://scenes/Enemy.tscn")
onready var ammoDrop = load("res://scenes/AmmoBox.tscn")

var ticks = 0

var maxEnemies = 4
var enemyCount = 0

var maxBoxes = 2
var boxCount = 0


func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spawn_enemy()

func get_random_position(max_height = 0.5):
	return Vector3(rng.randi_range(5,-5),rng.randi_range(0.5,max_height),rng.randi_range(5,-5))

func spawn_drop():
	if(boxCount < maxBoxes):
		var box = ammoDrop.instance()
		box.translation = get_random_position()
		add_child(box)
		boxCount += 1

func report_pickup():
	boxCount -= 1
	
func spawn_enemy():
	if(enemyCount < maxEnemies):
		var enemy = enemyScene.instance()
		enemy.translation = get_random_position(10)
		add_child(enemy)
		enemyCount +=1

func report_dead():
	enemyCount -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("switch_view"):
		if fpCam.current:
			fpCam.current = false
			tpCam.current = true
			$Player.toggle_tpp()
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			tpCam.current = false
			fpCam.current = true
			$Player.toggle_tpp()
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_just_released("exit"):
		get_tree().quit()


func on_tick():
	if ticks == 3:
		spawn_enemy()
	
	if ticks == 5:
		spawn_drop()
	
	ticks += 1
	ticks %= 6
