class_name Cell

var territories: Array[Territory] = []

func add_territory(territory: Territory):
	if !territories.has(territory):
		territories.push_back(territory)

func remove_territory(territory: Territory):
	territories.erase(territory)
