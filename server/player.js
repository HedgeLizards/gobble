

export class Player {

	constructor(name, pos) {
		this.name = name;
		this.pos = pos;
	}

	view() {
		return {name: this.name, pos: this.pos.arr()};
	}

}
