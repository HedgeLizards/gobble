

export class Enemy {

	constructor(id, pos) {
		this.id = id;
		this.pos = pos;
	}

	view() {
		return {type: "enemyUpdated", id: this.id, pos: this.pos.arr()};
	}

}
