

export class Enemy {

	constructor(id, pos) {
		this.id = id;
		this.pos = pos;
		this.health = 10;
		this.cooldown = 0;
		this.isAttacking = false;
		this.target = null;
	}

	view() {
		return {type: "entityUpdated", id: this.id, skin: "knight", pos: this.pos.arr(), isEnemy: true};
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
		}];
	}

	range() {
		return 2;
	}

}
