

export class Enemy {

	constructor(id, pos) {
		this.id = id;
		this.pos = pos;
		this.health = 10;
	}

	view() {
		return {type: "entityUpdated", id: this.id, skin: "knight", pos: this.pos.arr(), isEnemy: true};
	}

}
