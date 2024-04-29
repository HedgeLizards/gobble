
import { Player } from "./player.js";
import { Enemy } from "./enemy.js";
import { Vec2 } from "./vec2.js";
import { EnemyKind } from "./enemykind.js";
import { Wave, planWave } from "./waves.js";
import { ActionMessage, WorldMessage, CreatePlayerMessage } from "./messages.js";

enum State {
	Start = "Start", // no players
	WaveStart = "WaveStart", // between waves; some players, no enemies
	Wave = "Wave", // fighting enemies; some players, some emenies
	GameOver = "GameOver", // all players dead, some enemies
};



export class Game {

	players: Map<string, Player>
	nextEnemyId: number
	enemies: Map<string, Enemy>
	removed: Array<string>
	size: Vec2
	state: State
	timeToWave: number
	timeToSpawn: number
	timeToRestart: number
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
		this.timeToRestart = 0;
		this.waveNum = 0;
	}

	addPlayer(id: string, data: CreatePlayerMessage) {
		if (this.players.has(id)){
			return "id " + id + " is already taken";
		}
		let player = new Player(id, {...data, pos: this.center(), alive: this.acceptNewPlayers(), health: data.maxhealth, weapon: "HandGun"});
		console.log("new player", player.name, player);
		this.players.set(player.id, player);
		return null;
	}

	getPlayer(id: string) {
		return this.players.get(id);
	}

	removePlayer(id: string) {
		this.removed.push(id);
		this.players.delete(id);
	}

	spawnEnemy(kind: EnemyKind) {
		let ratio = Math.random()
		let pos = pick_random([
			new Vec2(this.size.x * ratio, 0), // top
			new Vec2(this.size.x, this.size.y * ratio), // right
			new Vec2(this.size.x * ratio, this.size.y), // bottom
			new Vec2(0, this.size.y * ratio), // left
		]);
		let enemy = new Enemy("E:" + this.nextEnemyId++, pos, kind);
		this.enemies.set(enemy.id, enemy);
	}

	hitEntity(entityId: string, damage: number) {
		let enemy = this.enemies.get(entityId);
		if (enemy) {
			enemy.health -= damage;
			if (enemy.health <= 0) {
				this.removed.push(entityId);
				this.enemies.delete(entityId);
			}
			return;
		}
		let player = this.players.get(entityId);
		if (player) {
			player.health -= damage;
			if (player.health <= 0) {
				player.alive = false;
				this.removed.push(entityId);
			}
			return;
		}

	}

	update(delta: number): ActionMessage[] {
		let actions: ActionMessage[] = [];
		if (this.players.size === 0) {
			this.state = State.Start;
			return [];
		}
		if (this.state === State.Start) {
			for (let player of this.players.values()) {
				player.reset();
			}
			this.waveNum = 0;
			for (let enemy of this.enemies.values()) {
				actions.push({type: "entityDeleted", id: enemy.id})
			}
			this.enemies = new Map();
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
				for (let player of this.players.values()) {
					player.alive = true;
					player.health = Math.max(1, player.health);
					player.health += 40 * delta;
					player.health = Math.min(player.maxhealth, player.health);
				}
				this.timeToWave -= delta;
			}
		}
		if (this.state === State.Wave) {
			if (this.wave!.isOver() && this.enemies.size === 0) {
				this.state = State.WaveStart;
				this.timeToWave = 5;
				actions.push({type: "waveEnd", waveNum: this.waveNum});
			} else if ([...this.players.values()].filter(player => player.alive).length === 0) {
				this.state = State.GameOver;
				actions.push({type: "gameOver"});
				this.timeToRestart = 5;
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
		if (this.state === State.GameOver) {
			this.timeToRestart -= delta;
			if (this.timeToRestart <= 0) {
				this.state = State.Start;

			}
		}

		for (let removed of this.removed) {
			actions.push({type: "entityDeleted", id: removed});
		}
		this.removed = [];
		for (let player of this.players.values()){
			if (player.alive) {
				actions.push(player.view());
			}
		}
		return actions;
	}

	findNearestTarget(pos: Vec2): [Vec2, {pos: Vec2}, number] {
		let nearest = this.center();
		let nearestDist = pos.distanceTo(this.center()) + 1024;
		let target = {pos: this.center()};
		for (let player of this.players.values()) {
			if (!player.alive) continue;
			let dist = pos.distanceTo(player.pos);
			if (dist < nearestDist) {
				nearest = player.pos;
				nearestDist = dist;
				target = player;
			}
		}
		return [nearest, target, nearestDist];
	}

	acceptNewPlayers() {
		return this.waveNum <= 1 || this.state === State.WaveStart;
	}

	center() {
		return this.size.div(2);
	}

	viewWorld(): WorldMessage {
		return {type: "world", size: this.size};
	}
}


function pick_random<Type>(arr: Type[]): Type {
	return arr[Math.random() * arr.length | 0];
}
