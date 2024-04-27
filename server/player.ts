
import { Vec2 } from "./vec2.js"

export class Player {
	name: string
	skin: string
	pos: Vec2
	aim: number
	weapon: string
	health: number
	maxhealth: number
	activity: { type: "idle" | "shooting" }

	constructor(name: string, skin: string, pos: Vec2, aim: number, weapon: string, health: number, maxhealth: number) {
		this.name = name;
		this.skin = skin;
		this.pos = pos;
		this.aim = aim;
		this.weapon = weapon;
		this.health = health;
		this.maxhealth = maxhealth
		this.activity = { type: "idle" }
	}

	update(props: any) {
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
			activity: this.activity,
		};
	}

}
