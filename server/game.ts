
import { Player } from "./player.js";
import { Enemy } from "./enemy.js";
import { Vec2 } from "./vec2.js";
import { EnemyKind } from "./enemykind.js";
import { Wave, planWave } from "./waves.js";

enum State {
	Start = "Start", // no players
	WaveStart = "WaveStart", // between waves; some players, no enemies
	Wave = "Wave", // fighting enemies; some players, some emenies
	GameOver = "GameOver", // all players dead, some enemies
};



export class Game {

	players: Map<string, Player>
	nextEnemyId: number
	enemies: Map<number, Enemy>
	removed: Array<string | number>
	size: Vec2
	state: State
	timeToWave: number
	timeToSpawn: number
	waveNum: number
	wave?: Wave


	constructor(){
		this.players = new Map();
		this.nextEnemyId = 1000;
		this.enemies = new Map();
		this.removed = [];
		this.size = new Vec2(96, 96);

		this.state = State.Start;
		this.timeToWave = 0;
		this.timeToSpawn = 0;
		this.waveNum = 0;
	}

	addPlayer(player: Player) {
		if (this.players.has(player.name)){
			return "name " + player.name + " is already taken";
		}
		console.log("new player", player.name, player);
		this.players.set(player.name, player);
		return null;
	}

	updatePlayer(player: Player) {
		if (!this.players.has(player.name)){
			return "unknown player " + player.name;
		}
		this.players.set(player.name, player);
	}

	getPlayer(name: string) {
		return this.players.get(name);
	}

	removePlayer(name: string) {
		this.removed.push(name);
		this.players.delete(name);
	}

	spawnEnemy(kind: EnemyKind) {
		let ratio = Math.random()
		let pos = pick_random([
			new Vec2(this.size.x * ratio, 0), // top
			new Vec2(this.size.x, this.size.y * ratio), // right
			new Vec2(this.size.x * ratio, this.size.y), // bottom
			new Vec2(0, this.size.y * ratio), // left
		]);
		let enemy = new Enemy(this.nextEnemyId++, pos, kind);
		this.enemies.set(enemy.id, enemy);
	}

	hitEnemy(enemyId: number, damage: number) {
		let enemy = this.enemies.get(enemyId);
		if (!enemy) { return; }
		enemy.health -= damage;
		if (enemy.health <= 0) {
			this.removed.push(enemyId);
			this.enemies.delete(enemyId);
		}

	}

	update(delta: number) {
		let actions = [];
		if (this.players.size === 0) {
			this.state = State.Start;
			this.waveNum = 0;
			this.enemies = new Map();
			return [];
		}
		if (this.state === State.Start) {
			this.state = State.WaveStart;
			this.timeToWave = 5;
		}
		if (this.state === State.WaveStart) {
			if (this.timeToWave < 0) {
				this.state = State.Wave;
				this.waveNum++;
				this.wave = planWave(this.waveNum);
				this.timeToSpawn = 0;
				actions.push({type: "waveStart", waveNum: this.waveNum});
			} else {
				this.timeToWave -= delta;
			}
		}
		if (this.state === State.Wave) {
			if (this.wave!.isOver() && this.enemies.size === 0) {
				this.state = State.WaveStart;
				this.timeToWave = 5;
				actions.push({type: "waveEnd", waveNum: this.waveNum});
			} else {
				this.timeToSpawn -= delta;
				if (this.timeToSpawn <= 0) {
					let toSpawn = this.wave!.spawn();
					if (toSpawn) {
						this.spawnEnemy(toSpawn);
						this.timeToSpawn = 1;
					}
				}
				for (let enemy of this.enemies.values()) {
					actions.push(...enemy.update(delta, this))
				}
			}
		}

		for (let removed of this.removed) {
			actions.push({type: "entityDeleted", id: removed});
		}
		this.removed = [];
		for (let player of this.players.values()){
			actions.push(player.view());
		}
		return actions;
	}

	findNearestTarget(pos: Vec2): [Vec2, {pos: Vec2}, number] {
		let nearest = this.center();
		let nearestDist = pos.distanceTo(this.center()) + 1024;
		let target = {pos: this.center()};
		for (let player of this.players.values()) {
			let dist = pos.distanceTo(player.pos);
			if (dist < nearestDist) {
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


function pick_random<Type>(arr: Type[]): Type {
	return arr[Math.random() * arr.length | 0];
}
