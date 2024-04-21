

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
			aim: this.pos.directionTo(this.targetPos()),
			weapon: this.kind.weapon,
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
			pos: [this.pos.x, this.pos.y - 0.5],
			id: "@bullet_" + this.id + "_" + ((Math.random() * 1e6) | 0),
			playerId: this.id,
			rotation: this.pos.directionTo(target.pos),
			speed: 10,
			distance: this.range(),
			isEnemy: true,
			kind: this.kind.projectile,
		}];
	}

	range() {
		return this.kind.range;
	}

}
