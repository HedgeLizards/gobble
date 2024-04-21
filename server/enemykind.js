

export class EnemyKind {

	constructor(skin, health, range, weapon) {
		this.skin = skin;
		this.health = health;
		this.range = range;
		this.weapon = weapon;
	}
}

EnemyKind.Knight = new EnemyKind("knight", 10, 1, "Sword");
EnemyKind.Archer = new EnemyKind("archer", 10, 10, "Bow");
