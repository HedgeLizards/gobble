
import { EnemyKind, Knight, Archer, Guardian, Tower, Chest } from "./enemykind.js"


class Phase {

	spawns: EnemyKind[]

	constructor(...composition: (EnemyKind | [EnemyKind, number])[]) {
		this.spawns = [];
		for (let entry of composition) {
			if (entry instanceof Array) {
				let [kind, n] = entry;
				for (let i: number=0; i<n; ++i) {
					this.spawns.push(kind);
				}
			} else {
				this.spawns.push(entry);
			}
		}
	}

	isOver() {
		return this.spawns.length === 0;
	}

	spawn() {
		// pick a random element, remove it and return it;
		let index = Math.random() * this.spawns.length | 0;
		let last = this.spawns.pop();
		if (last === undefined) {
			return undefined;
		}
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

export function planWave(waveNum: number) {
	const waveType = (waveNum - 1) % 5;
	const waveTypeNum = (waveNum - 1 - waveType) / 5;

	switch (waveType) {
		case 0:
			return new Wave(
				new Phase([Knight, 5 + waveTypeNum * 14], [Archer, 3 + waveTypeNum * 10]),
			);
		case 1:
			return new Wave(
				new Phase([Guardian, 3 + waveTypeNum * 10]),
				new Phase([Archer, 6 + waveTypeNum * 10]),
			);
		case 2:
			return new Wave(
				new Phase([Tower, 1 + waveTypeNum * 6]),
				new Phase([Knight, 10 + waveTypeNum * 14], [Archer, 3 + waveTypeNum * 10], [Chest, 1]),
			);
		case 3:
			return new Wave(
				new Phase([Guardian, 3 + waveTypeNum * 10]),
				new Phase([Knight, 5 + waveTypeNum * 14], [Tower, 2 + waveTypeNum * 6]),
			);
		case 4:
			return new Wave(
				new Phase([Knight, 5 + waveTypeNum * 14], [Archer, 3 + waveTypeNum * 10], [Guardian, 6 + waveTypeNum * 10], [Tower, 1 + waveTypeNum * 6], [Chest, 2]),
			);
	}
}
