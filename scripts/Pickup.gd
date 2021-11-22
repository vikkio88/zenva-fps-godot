extends Area


enum PickupType {
	HealthPack,
	AmmoBox
}

export(PickupType) var type = PickupType.AmmoBox
export var value:int = 10

var bobMaxHeight = 1
var bobbingUp = false
var bobSpeed = .02

onready var initialY = translation.y
onready var main: Node = get_node("/root/MainScene")

func _process(delta):
	translation.y += (1 if bobbingUp else -1) * bobSpeed
	if translation.y > bobMaxHeight:
		bobbingUp = false
	elif translation.y < 0:
		bobbingUp = true

	


func _on_Pickup_body_entered(body):
	if body.name == "Player":
		if type == PickupType.AmmoBox:
			body.give_ammo(value)
		else:
			body.give_health(value)
		if main.has_method('report_dead'):
			main.report_pickup()
		queue_free()
