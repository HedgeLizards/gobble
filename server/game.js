
import { Player } from "./player.js";
import { Enemy } from "./enemy.js";
import { Vec2 } from "./vec2.js";

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

	spawnEnemy(pos) {
		let enemy = new Enemy(this.nextEnemyId++, pos);
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
		++this.tick;
		this.timeToSpawn -= delta;
		if (this.timeToSpawn <= 0) {
			this.spawnEnemy(new Vec2(0, 0));
			this.timeToSpawn += 2;
		}
		if (this.enemies.size > 100) {
			this.enemies.delete(this.enemies.keys()[Math.random()]);
		}
		for (let enemy of this.enemies.values()) {
			enemy.pos = enemy.pos.add(this.center().sub(enemy.pos).normalize().mul(2 * delta));
		}
	}

	center() {
		return this.size.div(2);
	}

	view() {
		let actions = [];
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

	viewWorld() {
		return {type: "world", size: this.size.arr()};
	}
}
