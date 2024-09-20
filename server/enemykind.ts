
export interface EnemyKind {
	attackCooldown: number
	speed: number
	skin: string
	health: number
	range: number
	weapon?: string
	gold: number
	attackMove: boolean
	buildingDamage: number
}

export const Knight: EnemyKind = {skin: "Knight", health: 10, range: 1, weapon: "Sword", attackMove: false, attackCooldown: 1, speed: 2, gold: 1, buildingDamage: 3};
export const Archer: EnemyKind = {skin: "Archer", health: 10, range: 10, weapon: "Bow", attackMove: false, attackCooldown: 1, speed: 2, gold: 1, buildingDamage: 3};
export const Guardian: EnemyKind = {skin: "Guardian", health: 25, range: 1, weapon: "Shield", attackMove: false, attackCooldown: 2, speed: 2, gold: 2, buildingDamage: 3};
export const Tower: EnemyKind = {skin: "Tower", health: 40, range: 10, weapon: "Tower", attackMove: true, attackCooldown: 1, speed: 2, gold: 4, buildingDamage: 25};
export const Chest: EnemyKind = {skin: "Chest", health: 50, range: Infinity, attackMove: false, attackCooldown: 0.1, speed: 5, gold: 24, buildingDamage: 0};
export const Arthur: EnemyKind = {skin: "Arthur", health: 420, range: 2, weapon: "GoldenSword", attackMove: true, attackCooldown: 1, speed: 9, gold: 42, buildingDamage: 69};
