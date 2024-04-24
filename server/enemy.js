

import { Vec2 } from "./vec2.js";


export class Enemy {

	constructor(id, pos, kind) {
		this.id = id;
		this.pos = pos;
		this.health = kind.health;
		this.cooldown = 0;
		this.target = null;
		this.kind = kind;
	}

	update(delta, world) {
		let actions = [];
		this.isAttacking = false;
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

	view() {
		return {
			type: "entityUpdated",
			id: this.id,
			skin: this.kind.skin,
			pos: this.pos.arr(),
			aim: this.pos.directionTo(this.targetPos()),
			weapon: this.kind.weapon,
			isEnemy: true
		};
	}

	targetPos() {
		if (this.target) {
			return this.target.pos;
		} else {
			return this.pos;
		}
	}

	attack(target) {
		return [{
			type: "projectileCreated",
			pos: [this.pos.x, this.pos.y - 0.5],
			id: "@bullet_" + this.id + "_" + ((Math.random() * 1e6) | 0),
			playerId: this.id,
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
