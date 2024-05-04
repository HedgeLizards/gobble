
export interface EnemyKind {
	attackCooldown: number
	speed: number
	skin: string
	health: number
	range: number
	weapon: string
	damage: number


}

export const Knight: EnemyKind = {skin: "Knight", health: 10, range: 1, weapon: "Sword", damage: 5, attackCooldown: 1, speed: 2};
export const Archer: EnemyKind = {skin: "Archer", health: 10, range: 10, weapon: "Bow", damage: 3, attackCooldown: 1, speed: 2};
