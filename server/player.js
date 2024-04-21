

export class Player {

	constructor(name, skin, pos, aim) {
		this.name = name;
		this.skin = skin;
		this.pos = pos;
		this.aim = aim;
	}

	view() {
		return {type: "entityUpdated", id: this.name, skin: this.skin, pos: this.pos.arr(), aim: this.aim, isEnemy: false};
	}

}
