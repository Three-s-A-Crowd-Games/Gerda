extends RefCounted


class_name Mutator

var type :MutatorType
var category :MutatorCategory
var modifier :float
var title :String
var description :String
var texture :Vector2

const modifier_dict = {
	MutatorType.HARDENED_STONE: 	[1.4,1.8,2.2],
	MutatorType.LESS_ORE: 			[1.1,1.125,1.15],
	MutatorType.MORE_STONE: 		[1.25,1.5,1.75],
	MutatorType.SPAWN_PLUS: 		[1, 2, 3],
	MutatorType.DAMAGE_PLUS: 		[1.0,2.0,3.0],
	MutatorType.HEALTH_PLUS: 		[1.0,2.0,3.0],
	MutatorType.SPEED_UP: 			[1.2,1.4,1.6],
	MutatorType.SPEED_DOWN: 		[1.2,1.4,1.6]
}

const title_dict = {
	MutatorType.HARDENED_STONE: "Hardened Stone",
	MutatorType.LESS_ORE: "Less Ore",
	MutatorType.MORE_STONE: "More Stone",
	MutatorType.SPAWN_PLUS: "Enemy Spawn",
	MutatorType.DAMAGE_PLUS: "Enemy Damage",
	MutatorType.HEALTH_PLUS: "Enemy Health",
	MutatorType.SPEED_UP: "Speed Up",
	MutatorType.SPEED_DOWN: "Speed Down"
}

const description_dict = {
	MutatorType.HARDENED_STONE: "That's a hard rock.",
	MutatorType.LESS_ORE: "Minerals are getting scarce.",
	MutatorType.MORE_STONE: "Less caves, more mining.",
	MutatorType.SPAWN_PLUS: "Enemies. More of them.",
	MutatorType.DAMAGE_PLUS: "That's a lot of damage!",
	MutatorType.HEALTH_PLUS: "Did they buy armor?",
	MutatorType.SPEED_UP: "Gotta go fast!",
	MutatorType.SPEED_DOWN: "You gotta slow down sometimes."
}

## Contains the y-texture-coordinate for the Mutator
const tex_dict = {
	MutatorType.HARDENED_STONE: 30,
	MutatorType.LESS_ORE: 40,
	MutatorType.MORE_STONE: 50,
	MutatorType.SPAWN_PLUS: 0,
	MutatorType.DAMAGE_PLUS: 10,
	MutatorType.HEALTH_PLUS: 20,
	MutatorType.SPEED_UP: 70,
	MutatorType.SPEED_DOWN: 60
}

const category_dict = {
	MutatorCategory.WORLD_MUTATORS: [MutatorType.HARDENED_STONE, MutatorType.LESS_ORE, MutatorType.MORE_STONE],
	MutatorCategory.ENEMY_MUTATORS: [MutatorType.SPAWN_PLUS, MutatorType.DAMAGE_PLUS, MutatorType.HEALTH_PLUS],
	MutatorCategory.SPEED_MUTATORS: [MutatorType.SPEED_UP, MutatorType.SPEED_DOWN]
}

enum MutatorCategory {
	WORLD_MUTATORS,
	ENEMY_MUTATORS,
	SPEED_MUTATORS
}

enum MutatorType {
	HARDENED_STONE,
	LESS_ORE,
	MORE_STONE,
	SPAWN_PLUS,
	DAMAGE_PLUS,
	HEALTH_PLUS,
	SPEED_UP,
	SPEED_DOWN
}


## Returns a new Mutator-Instance of the given type and strength
## Strength levels: 0,1,2
func _init(wanted_type :MutatorType, strength :int):
	self.type = wanted_type
	self.category = Mutator.category_for_type(wanted_type)
	self.modifier = modifier_dict[wanted_type][strength]
	self.title = title_dict[wanted_type]
	self.description = description_dict[wanted_type]
	self.texture = Vector2i(Mutator.get_tex_x(strength), tex_dict[wanted_type])


## Returns the category of a type
static func category_for_type(wanted_type :MutatorType) -> MutatorCategory:
	for cat in category_dict:
		if category_dict[cat].has(wanted_type): return cat
	# Random default as fallback
	return MutatorCategory.WORLD_MUTATORS


## Returns an array of all MutatorTypes in the given MutatorCategory
static func types_for_category(wanted_category :MutatorCategory) -> Array:
	return category_dict[wanted_category]


## Get's the x-texture-coordinate of the mutator-strength
static func get_tex_x(strength :int) -> int:
	match strength:
		0:
			return 24
		1:
			return 12
		2:
			return 0
		_:
			return 0
