

export class Vec2 {
	x: number
	y: number

	constructor(x: number, y: number) {
		this.x = x;
		this.y = y;
	}

	equals(other: Vec2): boolean {
		return this.x === other.x && this.y === other.y;
	}

	surface(): number {
		return this.x * this.y;
	}

	length(): number {
		return Math.hypot(this.x, this.y);
	}

	mLength(): number {
		return Math.abs(this.x) + Math.abs(this.y);
	}

	add(v: Vec2): Vec2 {
		return new Vec2(this.x + v.x, this.y + v.y);
	}

	sub(v: Vec2): Vec2 {
		return new Vec2(this.x - v.x, this.y - v.y);
	}

	mul(n: number): Vec2 {
		return new Vec2(this.x * n, this.y * n);
	}

	div(n: number): Vec2 {
		return new Vec2(this.x / n, this.y / n);
	}

	floor(): Vec2 {
		return new Vec2(Math.floor(this.x), Math.floor(this.y));
	}

	round(): Vec2 {
		return new Vec2(Math.round(this.x), Math.round(this.y));
	}

	ceil(): Vec2 {
		return new Vec2(Math.ceil(this.x), Math.ceil(this.y));
	}

	normalize(): Vec2 {
		return this.div(this.length());
	}

	lerp(to: Vec2, d: number): Vec2 {
		return new Vec2(this.x*(1-d) + to.x*d, this.y*(1-d) + to.y*d);
	}

	distanceTo(other: Vec2): number {
		return this.sub(other).length();
	}

	mDistanceTo(other: Vec2): number {
		return this.sub(other).mLength();
	}

	directionTo(other: Vec2): number {
		return Math.atan2(other.y - this.y, other.x - this.x);
	}

	clone(): Vec2 {
		return new Vec2(this.x, this.y);
	}

	arr(): [number, number] {
		return [this.x, this.y];
	}

	truncate(maxSize: number): Vec2 {
		let len = this.length();
		if (len > maxSize) {
			return this.mul(maxSize / len);
		} else {
			return this;
		}
	}
}
