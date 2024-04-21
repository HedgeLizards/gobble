

export class Player {

	constructor(name, skin, pos, aim, weapon) {
		this.name = name;
		this.skin = skin;
		this.pos = pos;
		this.aim = aim;
		this.weapon = weapon;
	}

	view() {
		return {
			type: "entityUpdated",
			id: this.name,
			skin: this.skin,
			pos: this.pos.arr(),
			aim: this.aim,
			weapon: this.weapon,
			isEnemy: false
		};
	}

}
