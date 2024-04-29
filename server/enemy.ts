

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
		let [nearest, target, dist] = world.findNearestTarget(this.pos);
		this.target = target;
		if (dist < this.range()) {
			if (this.cooldown <= 0) {
				this.cooldown = this.kind.attackCooldown;
				if (Math.random() < 0.1) {
					this.pos = this.pos.add(new Vec2(Math.random(), Math.random()).truncate(this.kind.speed * delta));
				} else {
					actions.push(...this.attack(target));
				}
			}
		} else {
			let movement = this.targetPos().sub(this.pos).truncate(this.kind.speed * delta);
			this.pos = this.pos.add(movement);
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
			speed: 10,
			damage: this.kind.damage,
			distance: this.range(),
			isEnemy: true,
			kind: this.kind.projectile,
		}];
	}

	range() {
		return this.kind.range;
	}

}
