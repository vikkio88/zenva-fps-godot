extends KinematicBody

var health:int = 5

var moveSpeed:float = 2.0

var gravity = 10.0

var damage = 1
var attackRate = 1.0
var attackDist = 2.0

var scoreGiven = 10

onready var splat: AudioStreamPlayer = $Splat
onready var player: Node = get_node("/root/MainScene/Player")
onready var main: Node = get_node("/root/MainScene")
onready var timer: Timer = $Timer

var vel: Vector3 = Vector3.ZERO


func _ready():
	timer.set_wait_time(attackRate)
	timer.start()
	# wtf dude
	splat.stream.loop = false

func _physics_process(delta):
	var dir = Vector3.ZERO
	
	if !is_on_floor():
		dir.y -= gravity * delta * 2
	else:
		dir = (player.translation - translation).normalized()
		dir.y = 0
		
	dir = dir.normalized()
	
	if translation.distance_to(player.translation) > attackDist:
		move_and_slide(dir * moveSpeed, Vector3.UP)
func attack():
	player.take_damage(damage)

func tick():
	if translation.distance_to(player.translation) < attackDist:
		attack()

func die():
	if main.has_method('report_dead'):
		main.report_dead()
	queue_free()
		
func take_damage(damage):
	health -= damage
	var new_mat = $MeshInstance.get_surface_material(0).duplicate()
	new_mat.albedo_color = Color(1+((health - 5.0)/5.0),0,0)
	$MeshInstance.set_surface_material(0,new_mat)
	$Splat.play()
	if health <=0:
		die()

