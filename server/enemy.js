

export class Enemy {

	constructor(id, pos, kind) {
		this.id = id;
		this.pos = pos;
		this.health = kind.health;
		this.cooldown = 0;
		this.isAttacking = false;
		this.target = null;
		this.kind = kind;
	}

	view() {
		return {
			type: "entityUpdated",
			id: this.id,
			skin: this.kind.skin,
			pos: this.pos.arr(),
			isEnemy: true
		};
	}

	targetPos() {
		if (this.target) {
			return this.target.pos;
		} else {
			return this.pos;
		}
	}

	attack(target) {
		this.isAttacking = true;
		return [{
			type: "projectileCreated",
			pos: this.pos.arr(),
			id: "@bullet_" + this.id + "_" + ((Math.random() * 1e6) | 0),
			playerId: this.id,
			rotation: this.pos.directionTo(target.pos),
			speed: 10,
			distance: 10,
			isEnemy: true
		}];
	}

	range() {
		return this.kind.range;
	}

}
