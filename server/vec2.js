

export class Vec2 {

	constructor(x, y) {
		this.x = x;
		this.y = y;
	}

	equals(other) {
		return this.x === other.x && this.y === other.y;
	}

	surface() {
		return this.x * this.y;
	}

	length() {
		return Math.hypot(this.x, this.y);
	}

	mLength() {
		return Math.abs(this.x) + Math.abs(this.y);
	}

	add(v) {
		return new Vec2(this.x + v.x, this.y + v.y);
	}

	sub(v) {
		return new Vec2(this.x - v.x, this.y - v.y);
	}

	mul(n) {
		return new Vec2(this.x * n, this.y * n);
	}

	div(n) {
		return new Vec2(this.x / n, this.y / n);
	}

	floor() {
		return new Vec2(Math.floor(this.x), Math.floor(this.y));
	}

	round() {
		return new Vec2(Math.round(this.x), Math.round(this.y));
	}

	ceil() {
		return new Vec2(Math.ceil(this.x), Math.ceil(this.y));
	}

	normalize() {
		return this.div(this.length());
	}

	lerp(to, d) {
		return new Vec2(this.x*(1-d) + to.x*d, this.y*(1-d) + to.y*d);
	}

	distanceTo(other) {
		return this.sub(other).length();
	}

	mDistanceTo(other) {
		return this.sub(other).mLength();
	}

	clone() {
		return new Vec2(this.x, this.y);
	}

	arr() {
		return [this.x, this.y];
	}
}
