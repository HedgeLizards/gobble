

export class EnemyKind {

	constructor(skin, health, range) {
		this.skin = skin;
		this.health = health;
		this.range = range
	}
}

EnemyKind.Knight = new EnemyKind("knight", 10, 1);
EnemyKind.Archer = new EnemyKind("archer", 10, 10);
