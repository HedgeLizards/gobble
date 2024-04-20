

export class Player {

	constructor(name, skin, pos) {
		this.name = name;
		this.skin = skin;
		this.pos = pos;
	}

	view() {
		return {type: "entityUpdated", id: this.name, skin: this.skin, pos: this.pos.arr(), isEnemy: false};
	}

}
