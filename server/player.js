

export class Player {

	constructor(name, pos) {
		this.name = name;
		this.pos = pos;
	}

	view() {
		return {type: "playerUpdated", id: this.name, pos: this.pos.arr()};
	}

}
