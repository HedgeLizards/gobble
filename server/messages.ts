
import { union, literal, number, object, string, tuple, boolean, array, optional, enums, Infer } from 'superstruct'

const CreatePlayerMessage = object({
	type: literal("createPlayer"),
	id: string(),
	skin: string(),
	pos: tuple([number(), number()]),
	aim: number(),
	health: number(),
	maxhealth: number(),
	weapon: string(),
});
const UpdatePlayerMessage = object({
	type: literal("updatePlayer"),
	pos: tuple([number(), number()]),
	aim: number(),
	health: number(),
	weapon: string(),
	activity: optional(object({type: enums(["idle", "shooting"])}))
});
const ProjectileState = object({
	id: string(),
	pos: tuple([number(), number()]),
	rotation: number(),
	speed: number(),
	distance: number(),
	damage: number(),
	kind: string(),
});
const CreateProjectile = object({
	type: literal("createProjectiles"),
	creatorId: union([string(), number()]),
	isEnemy: boolean(),
	projectiles: array(ProjectileState),
});
const ImpactProjectile = object({
	type: literal("impactProjectile"),
	creatorId: union([string(), number()]),
	id: string(),
	impactedId: union([number(), string()]),
	pos: tuple([number(), number()]),
	damage: number(),
	kind: string(),
})
export const ClientMessage = union([CreatePlayerMessage, UpdatePlayerMessage, CreateProjectile, ImpactProjectile]);
export type ClientMessage = Infer<typeof ClientMessage>;

export type ActionMessage =
	{type: "entityUpdated", id: string | number, skin: string, pos: [number, number], aim: number, weapon: string, isEnemy: boolean, health: number, maxhealth: number, activity?: {type: "idle" | "shooting" }} |
	{type: "entityDeleted", id: string | number} |
	{type: "projectileCreated", id: string, creatorId: number | string, pos: [number, number], rotation: number, speed: number, distance: number, isEnemy: boolean, kind: string, damage: number} |
	{type: "projectileImpacted", id: string, creatorId: number | string, impactedId: string, pos: [number, number], damage: number} |
	{type: "waveStart", waveNum: number} |
	{type: "waveEnd", waveNum: number};

export type ServerMessage = {type: "update", actions: ActionMessage[]}
	| {type: "welcome", tickDuration: number, world: WorldMessage};

export type WorldMessage = {type: "world", size: [number, number]};