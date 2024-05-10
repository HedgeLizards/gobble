
export interface EnemyKind {
	attackCooldown: number
	speed: number
	skin: string
	health: number
	range: number
	weapon: string
	gold: number
}

export const Knight: EnemyKind = {skin: "Knight", health: 10, range: 1, weapon: "Sword", attackCooldown: 1, speed: 2, gold: 1};
export const Archer: EnemyKind = {skin: "Archer", health: 10, range: 10, weapon: "Bow", attackCooldown: 1, speed: 2, gold: 1};
