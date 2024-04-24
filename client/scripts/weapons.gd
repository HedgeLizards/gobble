extends Node


class Weapon:
	var texture: Resource
	var stream: Resource
	var volume_db: float
	var cooldown: float
	var bullets: int
	var spread: float
	var recoil_strength: float
	var bullet: String
	
	func _init(args):
		self.texture = args.texture
		self.stream = args.stream
		self.volume_db = args.volume_db
		self.cooldown = args.get("cooldown", 1.0)
		self.bullets = args.get("bullets", 1)
		self.spread = args.get("spread", 0.0)
		self.recoil_strength = args.get("recoil_strength", 0.0)
		self.bullet = args.get("bullet", "bullet")

var weapons: Dictionary = {
	"Handgun": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Gun.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"),
		"volume_db": 0.0,
		"cooldown": 0.4,
		"bullets": 1,
		"spread": PI / 180 * 2.5,
		"recoil_strength": 3.5,
	}),
	"AssaultRifle": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Assault_Rifle.png"),
		"stream": preload("res://sounds/SFX_AutomaticRifle_Fire.wav"),
		"volume_db": 0.0,
		"cooldown": 0.15,
		"bullets": 1,
		"spread": PI / 180 * 5,
		"recoil_strength": 3.5,
	}),
	"Minigun": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Minigun.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"), # TO DO: Replace with weapon-specific sound
		"volume_db": 0.0,
		"cooldown": 0.05,
		"bullets": 1,
		"spread": PI / 180 * 15,
		"recoil_strength": 5.5,
	}),
	"Sniper": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Sniper.png"),
		"stream": preload("res://sounds/SFX_SniperRifle_Fire.wav"),
		"volume_db": 0.0,
		"cooldown": 3.5,
		"bullets": 1,
		"spread": 0.0,
		"recoil_strength": 12.5,
	}),
	"Shotgun": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Shotgun.png"),
		"stream": preload("res://sounds/SFX_Shotgun_Fire.wav"),
		"volume_db": 0.0,
		"cooldown": 1.0,
		"bullets": 5,
		"spread": PI / 180 * 10,
		"recoil_strength": 12.5,
	}),
	"GrenadeLauncher": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Granande_Launcher.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"), # TO DO: Replace with weapon-specific sound
		"volume_db": 0.0,
		"cooldown": 3.5,
		"bullets": 1,
		"spread": 0.0,
		"recoil_strength": 15.0,
	}),
	"Bow": Weapon.new({
		"texture": preload("res://assets/Knights/knight_bow.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"), # TO DO: Replace with weapon-specific sound
		"volume_db": -80.0,
	}),
	"Sword": Weapon.new({
		"texture": preload("res://assets/Knights/Knight_sword.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"), # TO DO: Replace with weapon-specific sound
		"volume_db": -80.0,
	}),
}
