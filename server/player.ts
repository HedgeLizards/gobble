
import { Vec2 } from "./vec2.js";
import { ActionMessage } from "./messages.js";

export type Activity = { type: "idle" | "shooting"}

export class Player {
	id: string
	name: string
	alive: boolean
	skin: string
	pos: Vec2
	aim: number = 0;
	weapon: string
	health: number
	maxhealth: number
	activity: Activity

	constructor(id: string, p: {name: string, skin: string, pos: Vec2, weapon: string, health: number, maxhealth: number, alive: boolean}) {
		this.id = id;
		this.name = p.name;
		this.alive = p.alive;
		this.skin = p.skin;
		this.pos = p.pos;
		this.weapon = p.weapon;
		this.health = p.health;
		this.maxhealth = p.maxhealth
		this.activity = { type: "idle" }
	}

	update(p: {pos?: Vec2, aim?: number, weapon?: string, health?: number, maxhealth?: number, activity?: Activity}) {
		Object.assign(this, p);
	}

	reset() {
		this.health = this.maxhealth;
		this.alive = true;
	}

	view(): ActionMessage {
		return {
			type: "entityUpdated",
			id: this.id,
			name: this.name,
			alive: this.alive,
			skin: this.skin,
			pos: this.pos,
			aim: this.aim,
			weapon: this.weapon,
			isEnemy: false,
			health: this.health,
			maxhealth: this.maxhealth,
			activity: this.activity,
		};
	}

}
