extends Node

class Weapon:
	var texture: Resource
	var stream: Resource
	var volume_db: float
	var cooldown: float
	var bullets: int
	var spread: float
	var recoil_strength: float
	var projectile: String
	var speed: float
	var distance: float
	var damage: float
	
	func _init(args):
		self.texture = args.texture
		self.stream = args.get("stream")
		self.volume_db = args.get("volume_db", 0.0)
		self.cooldown = args.get("cooldown", 1.0)
		self.bullets = args.get("bullets", 1)
		self.spread = args.get("spread", 0.0)
		self.recoil_strength = args.get("recoil_strength", 0.0)
		self.projectile = args.get("projectile", "bullet")
		self.speed = args.get("speed", 60.0)
		self.distance = args.get("distance", 16.0)
		self.damage = args.get("damage", 5.0)

var weapons: Dictionary = {
	"Handgun": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Gun.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"),
		"cooldown": 0.5,
		"spread": PI / 180 * 2.5,
		"recoil_strength": 3.5,
	}),
	"AssaultRifle": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Assault_Rifle.png"),
		"stream": preload("res://sounds/SFX_AutomaticRifle_Fire.wav"),
		"cooldown": 0.2,
		"spread": PI / 180 * 5,
		"recoil_strength": 3.5,
	}),
	"Minigun": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Minigun.png"),
		"stream": preload("res://sounds/minigun.tres"),
		"cooldown": 0.05,
		"spread": PI / 180 * 15,
		"recoil_strength": 5.5,
		"damage": 3.0,
	}),
	"Sniper": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Sniper.png"),
		"stream": preload("res://sounds/SFX_SniperRifle_Fire.wav"),
		"cooldown": 2.5,
		"recoil_strength": 12.5,
		"distance": 24.0,
		"damage": 10.0,
	}),
	"Shotgun": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Shotgun.png"),
		"stream": preload("res://sounds/SFX_Shotgun_Fire.wav"),
		"bullets": 4,
		"spread": PI / 180 * 10,
		"recoil_strength": 12.5,
	}),
	"GrenadeLauncher": Weapon.new({
		"texture": preload("res://assets/Gobbles/Weapons/Gobble_Granande_Launcher.png"),
		"stream": preload("res://sounds/SFX_HandGun_Fire.wav"), # TO DO: Replace with weapon-specific sound
		"cooldown": 2.5,
		"recoil_strength": 15.0,
	}),
	"Sword": Weapon.new({
		"texture": preload("res://assets/Knights/sword.png"),
		"projectile": "sword",
		"speed": 10.0,
	}),
	"Bow": Weapon.new({
		"texture": preload("res://assets/Knights/bow.png"),
		"projectile": "arrow",
		"speed": 12.0,
		"damage": 3.0,
	}),
	"Shield": Weapon.new({
		"texture": preload("res://assets/Knights/shield.png"),
		"projectile": "shield",
		"speed": 10.0,
		"damage": 3.0,
	}),
	"Tower": Weapon.new({
		"texture": null,
		"projectile": "arrow",
		"speed": 12.0,
	}),
	"GoldenSword": Weapon.new({
		"texture": preload("res://assets/Knights/golden_sword.png"),
		"projectile": "golden_sword",
		"speed": 12.0,
		"damage": 25.0,
	}),
}
