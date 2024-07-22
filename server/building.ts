import { Vec2 } from "./vec2.js";
import { Game } from "./game.js";

export class Building {
    kind: string;
    pos: Vec2;
    size: Vec2;
    health: number;
    newHealth: number;
    interest: number;

    constructor(kind: string, pos: Vec2) {
        this.kind = kind;
        this.pos = pos;
        this.size = kinds[kind as keyof typeof kinds].size;
        this.health = kinds[kind as keyof typeof kinds].maxHealth;
        this.newHealth = this.health;
        this.interest = kind === "Bank" ? 1 : 0;
    }

    update(delta: number, world: Game) {
        const previousInterest = this.interest;

        if (this.kind === "Bank") {
            if (this.interest < 0) {
                const cost = Math.ceil(this.interest) + 1;

                world.gold -= cost;

                this.interest = cost - this.interest;
            }

            this.interest = Math.min(this.interest * 1.015 ** delta, 100);
        }

        const flooredInterest = Math.floor(this.interest);

        if (flooredInterest === previousInterest && this.newHealth === this.health) {
            return null;
        }

        const previousHealth = this.health;

        this.health = this.newHealth;

        return {
            type: "buildingUpdated" as const,
            pos: this.pos,
            health: this.health !== previousHealth ? this.health : undefined,
            interest: flooredInterest > previousInterest ? flooredInterest : undefined,
            gold: previousInterest < 0 ? world.gold : undefined,
        };
    }
};

export const kinds = {
    SwordStone: { size: new Vec2(2, 2), maxHealth: 1 },
    Armory: { size: new Vec2(1, 2), maxHealth: 20 },
    Bank: { size: new Vec2(1, 1), maxHealth: 10 },
    Wall: { size: new Vec2(1, 1), maxHealth: 20 },
}
