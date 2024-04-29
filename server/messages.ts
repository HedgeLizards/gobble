

import { define, coerce, union, literal, number, object, string, tuple, boolean, array, optional, enums, Infer } from 'superstruct'
import { Vec2 } from './vec2.js';
import { Activity } from './player.js';

const Vec2_ = coerce(define<Vec2>("Vec2", (o: any) => o instanceof Vec2), tuple([number(), number()]), ([x, y]) => new Vec2(x, y));
const PlayerId = define<string>("PlayerId", (o: any) => typeof(o) === "string" && o.startsWith("P:"));
const EnemyId = define<string>("EnemyId", (o: any) => typeof(o) === "string" && o.startsWith("E:"));
const EntityId = union([PlayerId, EnemyId]);
const ProjectileId = define<string>("ProjectileId", (o: any) => typeof(o) === "string" && o.startsWith("B:"));
const CreatePlayerMessage = object({
	type: literal("createPlayer"),
	id: PlayerId,
	name: string(),
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
	// health: number(),
	weapon: string(),
	activity: optional(object({type: enums(["idle", "shooting"])}))
});
const ProjectileState = object({
	id: ProjectileId,
	pos: Vec2_,
	rotation: number(),
	speed: number(),
	distance: number(),
	damage: number(),
	kind: string(),
});
const CreateProjectile = object({
	type: literal("createProjectiles"),
	creatorId: EntityId,
	isEnemy: boolean(),
	projectiles: array(ProjectileState),
});
const ImpactProjectile = object({
	type: literal("impactProjectile"),
	creatorId: EntityId,
	id: ProjectileId,
	impactedId: EntityId,
	pos: Vec2_,
	damage: number(),
	kind: string(),
})
export const ClientMessage = union([CreatePlayerMessage, UpdatePlayerMessage, CreateProjectile, ImpactProjectile]);
export type ClientMessage = Infer<typeof ClientMessage>;

export type ActionMessage =
	{type: "entityUpdated", id: string, name?: string, alive: boolean, skin: string, pos: Vec2, aim: number, weapon: string, isEnemy: boolean, health: number, maxhealth: number, activity?: Activity,} |
	{type: "entityDeleted", id: string} |
	{type: "projectileCreated", id: string, creatorId: string, pos: Vec2, rotation: number, speed: number, distance: number, isEnemy: boolean, kind: string, damage: number} |
	{type: "projectileImpacted", id: string, creatorId: string, impactedId: string, pos: Vec2, damage: number} |
	{type: "waveStart", waveNum: number} |
	{type: "waveEnd", waveNum: number} |
	{type: "gameOver"};

export type ServerMessage = {type: "update", actions: ActionMessage[]}
	| {type: "welcome", tickDuration: number, world: WorldMessage};

export type WorldMessage = {type: "world", size: Vec2};
