
import { Player } from "./player.js";
import { Enemy } from "./enemy.js";
import { Vec2 } from "./vec2.js";
import { EnemyKind } from "./enemykind.js";
import { Wave, planWave } from "./waves.js";
import { ActionMessage, WorldMessage, CreatePlayerMessage } from "./messages.js";
import { Building } from "./building.js";

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
	gold: number
	size: Vec2
	grid: (Building | null)[][]
	buildings: Building[]
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
		this.gold = 0;
		this.size = new Vec2(96, 96);
		this.grid = Array.from({ length: this.size.y }, () => Array(this.size.x).fill(null));
		this.buildings = [];
		this.addBuilding(0, "SwordStone", this.center().sub(new Vec2(1, 1)));

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
		let player = new Player(id, {...data, pos: this.center().add(new Vec2(0, 1.5)), alive: this.acceptNewPlayers(), health: data.maxhealth, weapon: "Handgun"});
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
				this.gold += enemy.kind.gold;
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

	addBuilding(cost: number, kind: string, pos: Vec2) {
		if (cost > this.gold) {
			return false;
		}

		const building = new Building(kind, pos);

		for (let r = 0; r < building.size.y; r++) {
			for (let c = 0; c < building.size.x; c++) {
				if (this.grid[pos.y + r][pos.x + c] !== null) {
					return false;
				}
			}
		}

		this.gold -= cost;

		for (let r = 0; r < building.size.y; r++) {
			for (let c = 0; c < building.size.x; c++) {
				this.grid[pos.y + r][pos.x + c] = building;
			}
		}

		this.buildings.push(building);

		return true;
	}

	removeBuilding(building: Building, index: number) {
		for (let r = 0; r < building.size.y; r++) {
			for (let c = 0; c < building.size.x; c++) {
				this.grid[building.pos.y + r][building.pos.x + c] = null;
			}
		}

		this.buildings.splice(index, 1);
	}

	update(delta: number): ActionMessage[] {
		let actions: ActionMessage[] = [];
		if (this.players.size === 0) {
			if (this.state !== State.Start) {
				this.state = State.Start;
				for (let i = this.buildings.length - 1; i > 0; i--) {
					this.removeBuilding(this.buildings[i], i);
				}
				this.gold = 0;
			}
			return [];
		}
		if (this.state === State.Start) {
			for (let player of this.players.values()) {
				player.reset();
			}
			this.waveNum = 0;
			for (let i = this.buildings.length - 1; i > 0; i--) {
				actions.push({type: "buildingDeleted", pos: this.buildings[i].pos});
				this.removeBuilding(this.buildings[i], i);
			}
			this.gold = 0;
			this.removed.push(...this.enemies.keys())
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
		for (const building of this.buildings) {
			const action = building.update(delta, this);
			if (action !== null) {
				actions.push(action);
			}
		}
		if (this.removed.length > 0) {
			actions.push({type: "entitiesDeleted", ids: this.removed, gold: this.gold});
			this.removed = [];
		}
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
		return {
			type: "world",
			size: this.size,
			buildings: this.buildings.map((building) => ({ kind: building.kind, pos: building.pos })),
			gold: this.gold,
		};
	}
}


function pick_random<Type>(arr: Type[]): Type {
	return arr[Math.random() * arr.length | 0];
}
