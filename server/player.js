

export class Player {

	constructor(name, skin, pos, aim, weapon, health, maxhealth) {
		this.name = name;
		this.skin = skin;
		this.pos = pos;
		this.aim = aim;
		this.weapon = weapon;
		this.health = health;
		this.maxhealth = maxhealth
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
			isEnemy: false,
			health: this.health,
			maxhealth: this.maxhealth,
		};
	}

}
