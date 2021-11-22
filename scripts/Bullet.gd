extends Area


var speed:float = 30.0
var damage:int=1

onready var bloodScene = load("res://scenes/Blood.tscn")

func _process(delta):
	translation += global_transform.basis.z * speed * delta

func destroy():
	queue_free()



func _on_Bullet_body_entered(body):
	if body.has_method("take_damage"):
		var blood = bloodScene.instance()
		body.add_child(blood)
		body.take_damage(damage)
		destroy()
