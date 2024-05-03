
export interface EnemyKind {
	attackCooldown: number
	speed: number
	skin: string
	health: number
	range: number
	weapon: string
	projectile: string
	damage: number


}

export const Knight: EnemyKind = {skin: "Knight", health: 10, range: 1, weapon: "Sword", projectile: "sword", damage: 5, attackCooldown: 1, speed: 2};
export const Archer: EnemyKind = {skin: "Archer", health: 10, range: 10, weapon: "Bow", projectile: "arrow", damage: 3, attackCooldown: 1, speed: 2};
