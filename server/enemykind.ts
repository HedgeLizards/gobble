
export class EnemyKind {
	attackCooldown: number
	speed: number
	skin: string
	health: number
	range: number
	weapon: string
	projectile: string
	damage: number

	constructor(args: any) {
		this.attackCooldown = 1;
		this.speed = 2;
		this.skin = args.skin;
		this.health = args.health;
		this.range = args.range;
		this.weapon = args.weapon;
		this.projectile = args.projectile;
		this.damage = args.damage;
	}

}

export const Knight = new EnemyKind({skin: "knight", health: 10, range: 1, weapon: "Sword", projectile: "sword", damage: 5});
export const Archer = new EnemyKind({skin: "archer", health: 10, range: 10, weapon: "Bow", projectile: "arrow", damage: 3});


