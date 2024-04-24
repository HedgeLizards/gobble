
import { EnemyKind } from "./enemykind.js"


class Phase {

	constructor(comp) {
		this.spawns = [];
		for (let name in comp) {
			for (let i=0; i<comp[name]; ++i) {
				this.spawns.push(EnemyKind[name]);
			}
		}
	}

	isOver() {
		return this.spawns.length === 0;
	}

	spawn() {
		if (this.isOver()) {
			return null;
		}
		// pick a random element, remove it and return it;
		let index = Math.random() * this.spawns.length | 0;
		let last = this.spawns.pop();
		if (index === this.spawns.length) {
			return last;
		} else {
			let spawned = this.spawns[index];
			this.spawns[index] = last;
			return spawned;
		}
	}
}


class Wave {
	constructor(phases) {
		this.phases = phases.map(p => new Phase(p));
	}

	spawn() {
		if (this.isOver()) {
			return null;
		}
		return this.phases[0].spawn();
	}

	isOver() {
		while (this.phases.length && this.phases[0].isOver()) {
			this.phases.shift();
		}
		return this.phases.length === 0;
	}
}

const waves = [
	[], // wave 0: unused
	[{Knight: 10, Archer: 6}],
	[{Knight: 20, Archer: 15}],
	[{Knight: 40, Archer: 30}],
	[{Knight: 60, Archer: 40}],
];
const lateWaves = [{Knight: 100, Archer: 100}];

export function planWave(waveNum) {
	if (waveNum < waves.length) {
		return new Wave(waves[waveNum]);
	} else {
		return new Wave(lateWaves);
	}
}
