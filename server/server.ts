import { type AddressInfo, WebSocketServer } from 'ws';

const wss = new WebSocketServer({ port: 8080 });
let connections = []

wss.once('listening', () => console.log(`Listening on :${(wss.address() as AddressInfo).port}`));

wss.on('connection', (socket) => {
	socket.send('Hello World');
	connections.push(new Connection(socket));
});


class Connection {

	socket: WebSocket
	player: Player

	constructor(socket) {
		this.socket = socket;
		this.socket.on("message", m => this.onMessage(m));
		this.player = null;
	}


	onMessage(m) {
		let data = JSON.parse(m);
		if (data.type === "introduction") {
			this.player = Player.fromMsg(data);
		} else if (data.type === "player") {
			this.player.pos = data.pos;
		}
		console.log(this.player.pos)
	}

	send(data) {
		this.socket.send(JSON.stringify(data))
	}
}



class Player {
	name: string
	pos: Vec2

	constructor(name: string, pos: Vec2) {
		this.name = name;
		this.pos = pos;
	}

	static fromMsg(data) {
		return new Player(data.name, data.pos);
	}
}


class Vec2 {
	x: number
	y: number

	constructor(x: number, y: number) {
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

