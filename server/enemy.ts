

import { Vec2 } from "./vec2.js";
import { EnemyKind } from "./enemykind.js";
import { Player } from "./player.js";
import { Game } from "./game.js";
import { ActionMessage } from "./messages.js";


export class Enemy {
	id: string
	pos: Vec2
	kind: EnemyKind
	cooldown: number
	target?: {pos: Vec2}
	health: number

	constructor(id: string, pos: Vec2, kind: EnemyKind) {
		this.id = id;
		this.pos = pos;
		this.health = kind.health;
		this.cooldown = 0;
		this.kind = kind;
	}

	update(delta: number, world: Game): ActionMessage[] {
		let actions: ActionMessage[] = [];
		let [target, dist] = world.findNearestTarget(this.pos);
		this.target = target === null ? { pos: world.center() } : target;
		let inRange = target === null ? !this.kind.hasOwnProperty("weapon") : dist < this.range();
		let newPos = null;
		if (inRange && this.cooldown <= 0) {
			this.cooldown = this.kind.attackCooldown;
			if (!this.kind.attackMove && Math.random() < 0.1) {
				let direction = new Vec2(Math.random(), Math.random());
				if (this.pos.x < 3 || this.pos.y < 3 || this.pos.x >= world.size.x - 3 || this.pos.y >= world.size.y - 3) {
					direction = direction.sub(this.pos.div(world.size));
				} else {
					direction = direction.sub(new Vec2(0.5, 0.5));
				}
				newPos = this.pos.add(direction.resize(this.kind.speed * delta));
			} else if (this.kind.hasOwnProperty("weapon")) {
				actions.push(...this.attack(this.target));
			}
		}
		if (!inRange || this.kind.attackMove) {
			let direction = this.targetPos().sub(this.pos);
			newPos = this.pos.add(direction.truncate(this.kind.speed * delta));
		}
		if (newPos !== null) {
			let building = world.grid[Math.floor(newPos.y)]?.[Math.floor(newPos.x)];
			if (building && building.kind !== "SwordStone") {
				building.newHealth = Math.max(building.newHealth - this.kind.buildingDamage * delta, 0);
			} else if (building?.kind === "SwordStone" && building.newHealth > 0 && newPos.equals(this.pos)) {
				building.newHealth = Math.max(building.newHealth - Infinity * delta, 0);
				if (building.newHealth === 0) {
					this.health = 0;
				}
			} else {
				this.pos = newPos;
			}
		}
		this.cooldown -= delta;
		actions.push(this.view());
		return actions;
	}

	view(): ActionMessage {
		return {
			type: "entityUpdated",
			id: this.id,
			skin: this.kind.skin,
			alive: true,
			pos: this.pos,
			aim: this.pos.directionTo(this.targetPos()),
			weapon: this.kind.weapon,
			isEnemy: true,
			health: this.health,
			maxhealth: this.kind.health,
		};
	}

	targetPos() {
		if (this.target) {
			return this.target.pos;
		} else {
			return this.pos;
		}
	}

	attack(target: {pos: Vec2}): ActionMessage[] {
		return [{
			type: "projectileCreated",
			pos: this.pos.add(new Vec2(0, -0.5)),
			id: "B:" + this.id + ";" + ((Math.random() * 1e6) | 0),
			creatorId: this.id,
			rotation: this.pos.directionTo(target.pos),
			isEnemy: true,
			weapon: this.kind.weapon as string,
		}];
	}

	range() {
		return this.kind.range;
	}

}
