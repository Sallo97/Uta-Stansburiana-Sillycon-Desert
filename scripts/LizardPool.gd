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

@export var lizard_scene : PackedScene

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


func spawn() -> Lizard:
	var liz: Lizard
	if __instances.size() <= MIN_COUNT:
		liz = __make_new_lizard()
	else:
		liz = __instances.pop_back()

	__root.add_child(liz)
	liz.add_to_group("Lizards")
	liz.set_process(true)
	liz.set_physics_process(true)
	Graphs.instance().lizard_spawned(liz)
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
func spawn_random() -> Lizard:
	var liz: Lizard = spawn()
	liz.set_random()
	return liz


func spawn_fixed(sex: Constants.Sex, morph: Constants.Morph) -> Lizard:
	var liz: Lizard = spawn()
	liz.set_fixed(sex, morph)
	return liz


func spawn_child(papa: Lizard, mama: Lizard) -> Lizard:
	var liz: Lizard = spawn()
	liz.set_child(papa, mama)
	return liz