extends Control


onready var healthBar = $Health
onready var ammo = $Ammo

func _ready():
	var playerNode = get_tree().get_root().find_node("Player", true, false)
	playerNode.connect("player_health_update", self, "update_health")
	playerNode.connect("player_ammo_update", self, "update_ammo")

func update_health(current, maxHp):
	healthBar.max_value = maxHp
	healthBar.value = current

func update_ammo(ammoLeft:int):
	ammo.text = "Ammo: " + String(ammoLeft)
	 
