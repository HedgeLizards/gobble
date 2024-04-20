import { WebSocketServer } from 'ws';

const wss = new WebSocketServer({ port: 8080 });
let connections = []

wss.once('listening', () => console.log(`Listening on :${wss.address().port}`));

wss.on('connection', (socket) => {
	socket.send(JSON.stringify({type: "Hello world"}));
	connections.push(new Connection(socket));
});


setInterval(update, 50);


function update() {

	let players = {};
	for (let connection of connections) {
		let player = connection.player;
		if (!player) { continue; }
		players[player.name] = player.view();
	}
	console.log(players);
	for (let connection of connections) {
		connection.send({type: "state", players: players});
	}
}

class Connection {


	constructor(socket) {
		this.socket = socket;
		this.socket.on("message", m => this.onMessage(m));
		this.player = null;
	}

	onMessage(m) {
		let data = JSON.parse(m);
		if (data.type === "introduction") {
			this.player = new Player(data.player, new Vec2(...data.pos));
		} else if (data.type === "player") {
			this.player.pos = new Vec2(...data.pos);
		}
	}

	send(data) {
		this.socket.send(JSON.stringify(data))
	}
}



class Player {

	constructor(name, pos) {
		this.name = name;
		this.pos = pos;
	}

	view() {
		return {name: this.name, pos: this.pos.arr()};
	}

}


class Vec2 {

	constructor(x, y) {
		this.x = x;
		this.y = y;
	}

	// static parse(obj) {
	// 	return new Vec2(obj.x, obj.y);
	// }

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

connections.push({send: () => {}, player: new Player("God", new Vec2(100, 200))});

