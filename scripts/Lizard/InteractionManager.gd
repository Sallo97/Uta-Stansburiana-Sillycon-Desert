class_name InteractionManager

static var lizs_interacting := []

static func start_interaction(l1: Lizard, l2: Lizard):
	if lizs_interacting.find(l1) != -1 || lizs_interacting.find(l2) != -1:
		return
	lizs_interacting.append(l1)
	lizs_interacting.append(l2)
	stop_lizard(l1, l2)
	
	
static func stop_lizard(l1:Lizard, l2:Lizard):
	l1.stop_velocity()
	l2.stop_velocity()
	var stop_timer: Timer = Timer.new()
	l1.get_tree().root.add_child(stop_timer)
	stop_timer.autostart = true
	stop_timer.one_shot = true
	stop_timer.wait_time = 0.5
	stop_timer.start()
	stop_timer.timeout.connect(arranging_them.bindv([l1,l2]))

static func arranging_them(l1:Lizard, l2:Lizard):
	l1.look_at_from_position(l1.position, l2.position)
	# l1.position += l1.global_transform * Vector3.BACK * 0.1
	l1.position -= (l2.position - l1.position) * 0.1
	deciding_interaction(l1,l2)

static func deciding_interaction(l1:Lizard, l2:Lizard):
	if(l1.sex != l2.sex):
		lizard_love(l1, l2)
	elif(l1.sex == Constants.Sex.MALE):
		lizard_fight(l1, l2)
	lizs_interacting = lizs_interacting.filter(
		func(l):
			return l != l1 && l != l2)

static func lizard_fight(l1:Lizard, l2:Lizard):
	print("Starting lizard fight!")
	l1.update_animation_parameters(1)
	l2.update_animation_parameters(1)
	#var prob_win_l1: float = 0.5
	#match l1.morph:
		#Constants.Morph.ORANGE:
			#prob_win_l1 += 0.2
		#Constants.Morph.YELLOW:
			#prob_win_l1 -= 0.2
#
	#match l2.morph:
		#Constants.Morph.ORANGE:
			#prob_win_l1 -= 0.2
		#Constants.Morph.YELLOW:
			#prob_win_l1 += 0.2		
	#
	#var win: bool = randf() <= prob_win_l1
	#if win:
		#LizardPool.instance().despawn(l2)
		#print(l2, " lost, is ded =(")
	#else:
		#LizardPool.instance().despawn(l1)
		#print(l1, " lost, is ded =(")

static func lizard_love(l1:Lizard, l2:Lizard):
	print("Starting lizard love!")
	l1.update_animation_parameters(2)
	l2.update_animation_parameters(2)
	l1.get_node("LoveParticles").emitting = true
	l2.get_node("LoveParticles").emitting = true
	#var prob_mate: float = 0.5
	#var male
	#if(l1.sex == Constants.Sex.MALE):
		#male = l1
	#else:
		#male = l2
		#
	#match male.morph:
		#Constants.Morph.ORANGE:
			#prob_mate += 0.2
		#Constants.Morph.BLUE:
			#prob_mate -= 0.1
		#Constants.Morph.YELLOW:
			#prob_mate -= 0.1
	
	#var mate: bool = randf() <= prob_mate
	#if mate:
		#print("BUM BUM QUAKA QUAKA A NEW CHILD IS BORN")
		## Chiamare una funzione in MainDesert che genera un nuovo figlio
	#else:
		#print("Better luck next time!")
		
	
