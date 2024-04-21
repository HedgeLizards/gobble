

export class Enemy {

	constructor(id, pos) {
		this.id = id;
		this.pos = pos;
		this.health = 10;
		this.cooldown = Math.random() * 0.5;
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

	attack() {

		return []
	}

	range() {
		return 2;
	}

}
