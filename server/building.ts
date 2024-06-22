import { Vec2 } from "./vec2.js";
import { Game } from "./game.js";

export class Building {
    kind: string;
    pos: Vec2;
    size: Vec2;
    interest: number;

    constructor(kind: string, pos: Vec2) {
        this.kind = kind;
        this.pos = pos;
        this.size = kinds[kind as keyof typeof kinds].size;
        this.interest = kind === "Bank" ? 1 : 0;
    }

    update(delta: number, world: Game) {
        if (this.kind === "Bank") {
            const previousInterest = this.interest;

            if (this.interest < 0) {
                const cost = Math.ceil(this.interest) + 1;

                world.gold -= cost;

                this.interest = cost - this.interest;
            }

            this.interest *= 1.03 ** delta;

            const flooredInterest = Math.floor(this.interest);

            if (flooredInterest > previousInterest) {
                return {
                    type: "buildingUpdated" as const,
                    pos: this.pos,
                    interest: flooredInterest,
                    gold: previousInterest < 0 ? world.gold : undefined,
                }
            }
        }

        return null;
    }
};

export const kinds = {
    SwordStone: { size: new Vec2(2, 2) },
    Armory: { size: new Vec2(1, 2) },
    Bank: { size: new Vec2(1, 1) },
    Wall: { size: new Vec2(1, 1) }
}
