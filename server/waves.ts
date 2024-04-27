
import { EnemyKind, Knight, Archer } from "./enemykind.js"


class Phase {

	spawns: EnemyKind[]

	constructor(...composition: (EnemyKind | [EnemyKind, number])[]) {
		this.spawns = [];
		for (let entry of composition) {
			if (entry instanceof EnemyKind) {
				this.spawns.push(entry);
			} else {
				let [kind, n] = entry;
				for (let i: number=0; i<n; ++i) {
					this.spawns.push(kind);
				}
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
		let last = this.spawns.pop() as EnemyKind;
		if (index === this.spawns.length) {
			return last;
		} else {
			let spawned = this.spawns[index];
			this.spawns[index] = last;
			return spawned;
		}
	}

	clone() {
		return new Phase(...this.spawns);
	}
}


export class Wave {
	phases: Phase[]
	constructor(...phases: Phase[]) {
		this.phases = phases;
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

	clone() {
		return new Wave(...this.phases.map(phase => phase.clone()));
	}
}

const waves: Wave[] = [
	new Wave(), // wave 0: unused
	new Wave(new Phase([Knight, 10], [Archer, 6])),
	new Wave(new Phase([Knight, 20], [Archer, 15])),
	new Wave(new Phase([Knight, 40], [Archer, 30])),
	new Wave(new Phase([Knight, 60], [Archer, 50])),
	new Wave(new Phase([Knight, 80], [Archer, 70])),
];
const lateWaves: Wave = new Wave(new Phase([Knight, 100],  [Archer, 100]));

export function planWave(waveNum: number): Wave {
	if (waveNum < waves.length) {
		return waves[waveNum].clone();
	} else {
		return lateWaves.clone();
	}
}
