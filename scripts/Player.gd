extends KinematicBody

var curHp:int = 2
const MAX_HP:int = 10

var ammo:int = 10
var score:int = 0

var moveSpeed:float = 5.0
var jumpForce:float = 40.0
var gravity:float = 75.0

var minLookAngle: float = -90.0
var maxLookAngle: float = 90.0
export var lookSensitivity: float = 60.0

var vel : Vector3 = Vector3()
var mouseDelta: Vector2 = Vector2()

var tppMode: bool = false

var gunCooldown = true

signal player_health_update(hp, maxHp)
signal player_ammo_update(ammo)

onready var gunshot: AudioStreamPlayer = $Gunshot
onready var gunclick: AudioStreamPlayer = $GunClick
onready var hurt: AudioStreamPlayer = $Hurt
onready var camera: Camera = $Camera
onready var muzzle: Spatial = $Camera/Muzzle
onready var bulletScene = load("res://scenes/Bullet.tscn")
onready var muzzleFlashScene = load("res://scenes/MuzzleFlash.tscn")
onready var bloodScene = load("res://scenes/Blood.tscn")

func _ready():
	# wtf dude
	gunshot.stream.loop = false
	gunclick.stream.loop = false
	hurt.stream.loop = false


func _physics_process(delta):
	vel.x = 0
	vel.z = 0
	
	var input = Vector2.ZERO
	
	if Input.is_action_pressed("move_fwd"):
		input.y -= 1
	if Input.is_action_pressed("move_bck"):
		input.y += 1
	
	if Input.is_action_pressed("move_l"):
		input.x -= 1
	if Input.is_action_pressed("move_r"):
		input.x += 1
	
	# to avoid diagonal speed being faster
	if input != Vector2.ZERO:
		input = input.normalized()
	
	# getting gloabal direction
	var fwd = global_transform.basis.z
	var right = global_transform.basis.x
	
	var relativeDir = (fwd * input.y + right * input.x)
	
	# set velocity
	vel.x = relativeDir.x * moveSpeed;
	vel.z = relativeDir.z * moveSpeed;
	
	vel.y -= gravity * delta * 2
	
	# apply velocity to player
	# second param is the direction of the ground?
	vel = move_and_slide(vel, Vector3.UP)
	
	if Input.is_action_pressed("jump") and is_on_floor():
		vel.y = jumpForce

func _process(delta):
	if !tppMode:
		camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)

	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	
	mouseDelta = Vector2()
	
	if Input.is_action_just_released("shoot") and ammo > 0 and gunCooldown:
		shoot()
	
	

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative


func shoot():
	var bullet = bulletScene.instance()
	var flash = muzzleFlashScene.instance()
#	muzzle.add_child(bullet)
	get_tree().get_root().add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	bullet.global_transform.basis.z *= -1
	muzzle.add_child(flash)
	
	ammo -=1
	emit_signal("player_ammo_update", ammo)
	gunshot.play()
	$AnimationPlayer.play("shoot")
	gunCooldown = false
	
func toggle_tpp():
	tppMode = !tppMode
	if tppMode:
		camera.rotation_degrees.x = 0
		
func take_damage(damage):
	$AnimationPlayer.play("hurt")
	hurt.play()
	var blood = bloodScene.instance()
	$Camera/CenterView.add_child(blood)
	curHp -= damage
	emit_signal("player_health_update", curHp, MAX_HP)
	if curHp <= 0:
		die()

func give_ammo(amount):
	ammo += amount
	emit_signal("player_ammo_update", ammo)

func give_health(amount):
	curHp += amount
	if curHp > MAX_HP:
		curHp = MAX_HP
	emit_signal("player_health_update", curHp, MAX_HP)
	

func die():
	print_debug("you ded")


func _on_Gunshot_finished():
	gunclick.play()
	$AnimationPlayer.stop()


func _on_GunClick_finished():
	gunCooldown = true
