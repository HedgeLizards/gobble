

export class Player {

	constructor(name, skin, pos, aim, weapon) {
		this.name = name;
		this.skin = skin;
		this.pos = pos;
		this.aim = aim;
		this.weapon = weapon;
		this.health = 100;
	}

	update(props) {
		Object.assign(this, props);
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
