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
	liz.add_to_group("Lizards")
	liz.set_process(true)
	liz.set_physics_process(true)
	return liz


func despawn(lizard: Lizard) -> void:
	if __instances.size() >= MAX_COUNT:
		lizard.free()
	else:
		lizard.get_parent().remove_child(lizard)
		lizard.remove_from_group("Lizards")
		lizard.set_process(false)
		lizard.set_physics_process(false)
		__instances.push_back(lizard)

	Graphs.instance().lizard_died(lizard)


# Shorthands
func spawn_random(prob_sex: float = 0.5, prob_orange: float = 1/3.0, prob_yellow: float = 1/3.0, prob_blue: float = 1/3.0) -> Lizard:
	var liz: Lizard = __spawn()
	liz.set_lizard_prob(prob_sex, prob_orange, prob_yellow, prob_blue)
	Graphs.instance().lizard_spawned(liz)
	return liz


func spawn_fixed(sex: Constants.Sex, morph: Constants.Morph) -> Lizard:
	var liz: Lizard = __spawn()
	liz.set_lizard_fixed(sex, morph)
	Graphs.instance().lizard_spawned(liz)
	return liz


func spawn_child(papa: Lizard, mama: Lizard) -> Lizard:
	var liz: Lizard = __spawn()
	liz.set_lizard_child(papa, mama)
	Graphs.instance().lizard_spawned(liz)
	return liz
