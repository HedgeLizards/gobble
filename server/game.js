
import { Player } from "./player.js";
import { Enemy } from "./enemy.js";
import { Vec2 } from "./vec2.js";
import { EnemyKind } from "./enemykind.js";

export class Game {

	constructor(){
		this.players = new Map();
		this.nextEnemyId = 1000;
		this.enemies = new Map();
		this.removed = [];
		this.size = new Vec2(128, 128);
		this.tick = 0;
		this.timeToSpawn = 2;
	}

	addPlayer(player) {
		if (this.players.has(player.name)){
			return "name " + player.name + " is already taken";
		}
		console.log("new player", player.name, player);
		this.players.set(player.name, player);
		return null;
	}

	updatePlayer(player) {
		if (!this.players.has(player.name)){
			return "unknown player " + player.name;
		}
		this.players.set(player.name, player);
	}

	removePlayer(name) {
		this.removed.push(name);
		this.players.delete(name);
	}

	spawnEnemy() {
		let pos = pick_random([new Vec2(0, 0), new Vec2(this.size.x, 0), new Vec2(this.size.x, this.size.y), new Vec2(0, this.size.y)]);
		let kind = pick_random([EnemyKind.Knight, EnemyKind.Archer])
		let enemy = new Enemy(this.nextEnemyId++, pos, kind);
		this.enemies.set(enemy.id, enemy);
	}

	hitEnemy(enemyId, damage) {
		let enemy = this.enemies.get(enemyId);
		if (!enemy) { return; }
		enemy.health -= damage;
		if (enemy.health <= 0) {
			this.removed.push(enemyId);
			this.enemies.delete(enemyId);
		}

	}

	update(delta) {
		let actions = [];
		++this.tick;
		this.timeToSpawn -= delta;
		if (this.timeToSpawn <= 0 && this.enemies.size < 100) {
			this.spawnEnemy();
			this.timeToSpawn = 2;
		}
		for (let enemy of this.enemies.values()) {
			if (enemy.cooldown < 0) {
				enemy.isAttacking = false;
				let [nearest, target, dist] = this.findNearestTarget(enemy.pos);
				enemy.target = target;
				if (dist < enemy.range()) {
					actions.push(...enemy.attack(target));
				}
				enemy.cooldown = 0.5;
			}
			enemy.cooldown -= delta;
			if (!enemy.isAttacking) {
				let movement = enemy.targetPos().sub(enemy.pos).truncate(2 * delta);
				enemy.pos = enemy.pos.add(movement);
			}
		}

		for (let removed of this.removed) {
			actions.push({type: "entityDeleted", id: removed});
		}
		this.removed = [];
		for (let player of this.players.values()){
			actions.push(player.view());
		}
		for (let enemy of this.enemies.values()){
			actions.push(enemy.view());
		}
		return actions;
	}

	findNearestTarget(pos) {
		let nearest = this.center();
		let nearestDist = pos.distanceTo(nearest);
		let target = {pos: this.center()};
		for (let player of this.players.values()) {
			let dist = pos.distanceTo(player.pos);
			if (dist < nearestDist && dist < 20) {
				nearest = player.pos;
				nearestDist = dist;
				target = player;
			}
		}
		return [nearest, target, nearestDist];
	}

	center() {
		return this.size.div(2);
	}

	view() {
	}

	viewWorld() {
		return {type: "world", size: this.size.arr()};
	}
}


function pick_random(arr) {
	return arr[Math.random() * arr.length | 0];
}
