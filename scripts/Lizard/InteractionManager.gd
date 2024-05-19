class_name InteractionManager

static var lizs_interacting := []

static func start_interaction(l1: Lizard, l2: Lizard):
	print("Sono dentro start interaction con ", l1, " e ", l2)
	if lizs_interacting.find(l1) != -1 || lizs_interacting.find(l2) != -1:
		return
	lizs_interacting.append(l1)
	lizs_interacting.append(l2)
	if(l1.sex != l2.sex):
		lizard_love(l1, l2)
	elif(l1.sex == Constants.Sex.MALE):
		lizard_fight(l1, l2)
	lizs_interacting = lizs_interacting.filter(
		func(l):
			return l != l1 && l != l2)
	
static func lizard_fight(l1:Lizard, l2:Lizard):
	print("Starting lizard fight!")
	var prob_win_l1: float = 0.5
	match l1.morph:
		Constants.Morph.ORANGE:
			prob_win_l1 += 0.2
		Constants.Morph.YELLOW:
			prob_win_l1 -= 0.2

	match l2.morph:
		Constants.Morph.ORANGE:
			prob_win_l1 -= 0.2
		Constants.Morph.YELLOW:
			prob_win_l1 += 0.2		
	
	var win: bool = randf() <= prob_win_l1
	if win:
		LizardPool.instance().despawn(l2)
		print(l2, " lost, is ded =(")
	else:
		LizardPool.instance().despawn(l1)
		print(l1, " lost, is ded =(")

static func lizard_love(l1:Lizard, l2:Lizard):
	print("Starting lizard love!")
	var prob_mate: float = 0.5
	var male
	if(l1.sex == Constants.Sex.MALE):
		male = l1
	else:
		male = l2
		
	match male.morph:
		Constants.Morph.ORANGE:
			prob_mate += 0.2
		Constants.Morph.BLUE:
			prob_mate -= 0.1
		Constants.Morph.YELLOW:
			prob_mate -= 0.1
	
	var mate: bool = randf() <= prob_mate
	if mate:
		print("BUM BUM QUAKA QUAKA A NEW CHILD IS BORN")
		# Chiamare una funzione in MainDesert che genera un nuovo figlio
	else:
		print("Better luck next time!")
		
	
