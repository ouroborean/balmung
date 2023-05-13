extends RefCounted

enum combat_style {
	WARRIOR,
	ASSASSIN,
	HUNTER,
	MAGE,
	SHAMAN,
	DEFENDER
}

var name = "DefaultName"
var hp = 100
var max_hp = 100
var style = combat_style.WARRIOR
var energy_regen
var base_energy
var energy

func _init(new_name, new_hp, style):
	name = new_name
	hp = new_hp
	max_hp = new_hp
	style = combat_style[style]
	match style:
		combat_style.WARRIOR:
			base_energy = 0.0
			energy_regen = 0.0
		combat_style.ASSASSIN:
			base_energy = 100
			energy_regen = 5.0
		combat_style.HUNTER:
			base_energy = 100
			energy_regen = 10.0
		combat_style.MAGE:
			base_energy = 300
			energy_regen = 0.0
		combat_style.SHAMAN:
			base_energy = 200
			energy_regen = 1.5
		combat_style.DEFENDER:
			base_energy = 100
			energy_regen = 1.0
	energy = base_energy

func can_use(ability):
	return ability.cooldown_remaining <= 0 and energy >= ability.cost
