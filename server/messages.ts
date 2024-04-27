

import { define, coerce, union, literal, number, object, string, tuple, boolean, array, optional, enums, Infer } from 'superstruct'
import { Vec2 } from './vec2.js';

const Vec2_ = coerce(define<Vec2>("Vec2", (o: any) => o instanceof Vec2), tuple([number(), number()]), ([x, y]) => new Vec2(x, y));
const CreatePlayerMessage = object({
	type: literal("createPlayer"),
	id: string(),
	skin: string(),
	pos: Vec2_,
	aim: number(),
	health: number(),
	maxhealth: number(),
	weapon: string(),
});
const UpdatePlayerMessage = object({
	type: literal("updatePlayer"),
	pos: Vec2_,
	aim: number(),
	health: number(),
	weapon: string(),
	activity: optional(object({type: enums(["idle", "shooting"])}))
});
const ProjectileState = object({
	id: string(),
	pos: Vec2_,
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
	pos: Vec2_,
	damage: number(),
	kind: string(),
})
export const ClientMessage = union([CreatePlayerMessage, UpdatePlayerMessage, CreateProjectile, ImpactProjectile]);
export type ClientMessage = Infer<typeof ClientMessage>;

export type ActionMessage =
	{type: "entityUpdated", id: string | number, skin: string, pos: Vec2, aim: number, weapon: string, isEnemy: boolean, health: number, maxhealth: number, activity?: {type: "idle" | "shooting" }} |
	{type: "entityDeleted", id: string | number} |
	{type: "projectileCreated", id: string, creatorId: number | string, pos: Vec2, rotation: number, speed: number, distance: number, isEnemy: boolean, kind: string, damage: number} |
	{type: "projectileImpacted", id: string, creatorId: number | string, impactedId: string, pos: Vec2, damage: number} |
	{type: "waveStart", waveNum: number} |
	{type: "waveEnd", waveNum: number};

export type ServerMessage = {type: "update", actions: ActionMessage[]}
	| {type: "welcome", tickDuration: number, world: WorldMessage};

export type WorldMessage = {type: "world", size: Vec2};
