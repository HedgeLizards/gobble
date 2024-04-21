

export class EnemyKind {

	constructor(skin, health, range, weapon, projectile) {
		this.skin = skin;
		this.health = health;
		this.range = range;
		this.weapon = weapon;
		this.projectile = projectile;
	}
}

EnemyKind.Knight = new EnemyKind("knight", 10, 1, "Sword", "sword");
EnemyKind.Archer = new EnemyKind("archer", 10, 10, "Bow", "arrow");
