
import { EnemyKind, EnemyKindId } from "./enemykind.js"


class Phase {

	spawns: EnemyKind[]

	constructor(composition: any) {
		this.spawns = [];
		for (let name in composition) {
			for (let i: number=0; i<composition[name]; ++i) {
				this.spawns.push(EnemyKind.fromStr(name as EnemyKindId));
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
}


export class Wave {
	phases: Phase[]
	constructor(phases: Phase[]) {
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

const waves: any[][] = [
	[], // wave 0: unused
	[{Knight: 10, Archer: 6}],
	[{Knight: 20, Archer: 15}],
	[{Knight: 40, Archer: 30}],
	[{Knight: 60, Archer: 40}],
];
const lateWaves: any[] = [{Knight: 100, Archer: 100}];

export function planWave(waveNum: number): Wave {
	if (waveNum < waves.length) {
		return new Wave(waves[waveNum]);
	} else {
		return new Wave(lateWaves);
	}
}
