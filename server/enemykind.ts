

export class EnemyKind {
	attackCooldown: number
	speed: number
	skin: string
	health: number
	range: number
	weapon: string
	projectile: string
	damage: number

	constructor(args) {
		this.attackCooldown = 1;
		this.speed = 2;
		Object.assign(this, args);
	}

	static Knight: EnemyKind
	static Archer: EnemyKind
}

EnemyKind.Knight = new EnemyKind({skin: "knight", health: 10, range: 1, weapon: "Sword", projectile: "sword", damage: 5});
EnemyKind.Archer = new EnemyKind({skin: "archer", health: 10, range: 10, weapon: "Bow", projectile: "arrow", damage: 3});
