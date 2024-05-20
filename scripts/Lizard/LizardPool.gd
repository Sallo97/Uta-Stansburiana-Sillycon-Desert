extends RefCounted
class_name LizardPool

static var __instance: LizardPool

func _init():
	assert(__instance == null)
	__instance = self

static func instance() -> LizardPool:
	if __instance == null:
		return LizardPool.new()
	else:
		return __instance


const WARM_COUNT = 30
const MAX_COUNT = 100
const MIN_COUNT = 0

var __root: Node
var __instances: Array[Lizard]

var lizard_scene: PackedScene = preload("res://scenes/lizard/lizard_logic.tscn")

func set_scene(root: Node):
	__root = root
	__setup()


func __setup():
	__instances = []
	for i in WARM_COUNT:
		__instances.push_back(__make_new_lizard())


func __make_new_lizard() -> Lizard:
	var newLizard: Lizard = lizard_scene.instantiate()
	newLizard.remove_from_group("Lizards")
	newLizard.remove_from_group("Children")
	newLizard.set_process(false)
	newLizard.set_physics_process(false)
	return newLizard


func __spawn() -> Lizard:
	var liz: Lizard
	if __instances.size() <= MIN_COUNT:
		liz = __make_new_lizard()
	else:
		liz = __instances.pop_back()

	__root.add_child(liz)
	liz.set_process(true)
	liz.position = Vector3.ZERO
	liz.velocity = Vector3.ZERO
	liz.rotation = Vector3.ZERO
	liz.set_physics_process(true)
	liz.show()

	var timer: Timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = 0.5
	timer.autostart = false
	timer.timeout.connect(__root.get_node("/root/Main/BaseDesert/Scripts/Grid").cell_entered.bind(liz))
	liz.cell_change_timer = timer
	liz.add_child(timer)
	timer.start()
	
	# print("lizard_group size: ", __root.get_tree().get_nodes_in_group("Lizards").size(), ", children_group size: ", __root.get_tree().get_nodes_in_group("Children").size())

	return liz


func despawn(lizard: Lizard) -> void:
	lizard.hide()
	var timer: Timer = lizard.cell_change_timer
	if timer != null && !timer.is_queued_for_deletion():
		timer.stop()
		lizard.remove_child(timer)
		lizard.cell_change_timer = null
		timer.queue_free()
	__despawn_deferred.bind(lizard).call_deferred()

func __despawn_deferred(lizard: Lizard) -> void:
	if lizard.is_queued_for_deletion():
		return
	
	var is_in_instances: bool = __instances.has(lizard)
	if is_in_instances:
		pass
	else:
		lizard.death_timer.stop()
		lizard.death_timer.queue_free()
		if __instances.size() >= MAX_COUNT:
			lizard.queue_free()
		else:
			lizard.get_parent().remove_child(lizard)
			lizard.remove_from_group("Lizards")
			lizard.remove_from_group("Children")
			lizard.set_process(false)
			lizard.set_physics_process(false)
			__instances.push_back(lizard)
		Graphs.instance().lizard_died(lizard)


# Shorthands
func spawn_random(prob_sex: float = 0.5, prob_orange: float = 1/3.0, prob_yellow: float = 1/3.0, prob_blue: float = 1/3.0) -> Lizard:
	var liz: Lizard = __spawn()
	liz.add_to_group("Lizards")
	liz.set_lizard_prob(prob_sex, prob_orange, prob_yellow, prob_blue)
	Graphs.instance().lizard_spawned(liz)
	return liz


func spawn_fixed(sex: Constants.Sex, morph: Constants.Morph) -> Lizard:
	var liz: Lizard = __spawn()
	liz.add_to_group("Lizards")
	liz.set_lizard_fixed(sex, morph)
	Graphs.instance().lizard_spawned(liz)
	return liz


func spawn_child(papa: Lizard, mama: Lizard) -> Lizard:
	var liz: Lizard = __spawn()
	liz.add_to_group("Children")
	liz.set_lizard_child(papa, mama)
	Graphs.instance().lizard_spawned(liz)
	return liz
