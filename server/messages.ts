

import { define, coerce, union, literal, number, object, string, tuple, boolean, array, optional, enums, Infer } from 'superstruct'
import { Vec2 } from './vec2.js';
import { kinds } from './building.js';
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
	maxhealth: number(),
});
export type CreatePlayerMessage = Infer<typeof CreatePlayerMessage>;
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
});
const CreateProjectiles = object({
	type: literal("createProjectiles"),
	creatorId: EntityId,
	isEnemy: boolean(),
	weapon: string(),
	projectiles: array(ProjectileState),
});
const ImpactProjectile = object({
	type: literal("impactProjectile"),
	creatorId: EntityId,
	id: ProjectileId,
	impactedIds: array(EntityId),
	pos: Vec2_,
	damage: number(),
	weapon: string(),
});
const CreateBuilding = object({
	type: literal("createBuilding"),
	cost: number(),
	kind: enums(Object.keys(kinds)),
	pos: Vec2_,
});
const BuyGun = object({
	type: literal("buyGun"),
	cost: number(),
	buyerId: PlayerId,
	weapon: string(),
});
const EmptyBank = object({
	type: literal("emptyBank"),
	pos: Vec2_,
})
export const ClientMessage = union([CreatePlayerMessage, UpdatePlayerMessage, CreateProjectiles, ImpactProjectile, CreateBuilding, BuyGun, EmptyBank]);
export type ClientMessage = Infer<typeof ClientMessage>;

export type ActionMessage =
	{type: "entityUpdated", id: string, name?: string, alive: boolean, skin: string, pos: Vec2, aim: number, weapon?: string, isEnemy: boolean, health: number, maxhealth: number, activity?: Activity,} |
	{type: "entitiesDeleted", ids: string[], gold: number} |
	{type: "projectileCreated", id: string, creatorId: string, pos: Vec2, rotation: number, isEnemy: boolean, weapon: string} |
	{type: "projectileImpacted", id: string, creatorId: string, impactedIds: string[], pos: Vec2, damage: number, weapon: string} |
	{type: "buildingCreated", kind: string, pos: Vec2, health: number, gold: number} |
	{type: "buildingUpdated", pos: Vec2, health?: number, interest?: number, gold?: number} |
	{type: "gunBought", buyerId: string, weapon: string, gold: number} |
	{type: "waveStart", waveNum: number} |
	{type: "waveEnd", waveNum: number} |
	{type: "gameOver"} |
	{type: "reset", world: WorldMessage};

export type ServerMessage = {type: "update", actions: ActionMessage[]}
	| {type: "welcome", tickDuration: number, world: WorldMessage}
	| {type: "reset", tickDuration: number, world: WorldMessage};

export type WorldMessage = {type: "world", size: Vec2, buildings: { kind: string, pos: Vec2, health: number }[], gold: number};
