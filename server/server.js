import { WebSocketServer } from 'ws';


function main() {
	let game = new Game()
	let server = new Serv(game, 8080);
	game.addPlayer(new Player("Satan", new Vec2(666, 666)));
	setInterval(() => server.update(), 50);
}


class Game {

	constructor(){
		this.players = new Map();
	}

	addPlayer(player) {
		if (this.players.has(player.name)){
			return "name " + player.name + " is already taken";
		}
		console.log("new player", player.name, player);

		this.players.set(player.name, player);
		return null;
	}

	updatePlayer(player) {
		if (!this.players.has(player.name)){
			return "unknown player " + player.name;
		}
		this.players.set(player.name, player);
	}

	removePlayer(name) {
		this.players.delete(name);
	}

	view() {
		let players = {}
		for (let player of this.players.values()){
			players[player.name] = player.view();
		}
		return {type: "state", players: players};
	}
}

class Serv {

	constructor(game, port) {
		this.game = game;
		this.playerIds = new Map();
		this.connections = new Map();
		this.nextId = 1;
		this.wss = new WebSocketServer({port: port});
		this.wss.once('listening', () => console.log(`Listening on :${this.wss.address().port}`));
		this.wss.on("connection", socket => {
			let id = this.nextId++;
			this.connections.set(id, socket);
			socket.on("close", msg => {
				this.connections.delete(id);
				let playerName = this.playerIds.get(id);
				if (playerName) {
					this.game.removePlayer(playerName);
				}
			});
			socket.on("message", msg => {
				let data = JSON.parse(msg);
				if (data.type === "introduction") {
					if (this.playerIds.has(id)) {
						send_error(socket, "Can only introduce once");
						return;
					}
					let name = data.player;
					if (!name) {
						send_error(socket, "invalid name " + name);
						return
					}
					this.playerIds.set(id, name);
					let err = this.game.addPlayer(new Player(name, new Vec2(...data.pos)));
					if (err) {
						send_error(socket, err);
					}
				} else if (data.type === "player") {
					let name = this.playerIds.get(id);
					if (!name) {
						send_error(socket, "Who the fuck are you?");
						return
					}
					let player = new Player(name, new Vec2(...data.pos))
					let err = this.game.updatePlayer(player);
					if (err) {
						send_error(socket, err);
						console.log(err);
					}
				}
			});
		});
	}


	update() {
		let data = this.game.view();
		// console.log(data.players);
		this.broadcast(data);
	}

	broadcast(data) {
		for (let socket of this.connections.values()) {
			socket.send(JSON.stringify(data));
		}
	}
}

function send_error(socket, msg) {
	console.warn(msg);
	socket.send(JSON.stringify({type: "error", msg: msg}));
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

main();

