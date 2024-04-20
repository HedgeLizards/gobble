import WebSocket, { WebSocketServer } from 'ws';
import { Vec2 } from './vec2.js';
import { Game } from './game.js';
import { Player } from './player.js';

const tickDuration = 0.1

function main() {
	let port = 9412
	if (process.argv.length >= 3) {
		port = Number.parseInt(process.argv[2]);
	}
	let game = new Game()
	let server = new Serv(game, port);
	setInterval(() => server.update(tickDuration), tickDuration * 1000);
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
				if (socket.readyState === WebSocket.CLOSING) {
					return;
				}
				let data = JSON.parse(msg);
				if (data.type === "createPlayer") {
					if (this.playerIds.has(id)) {
						send_error(socket, "Can only introduce once");
						return;
					}
					let name = data.id;
					if (!name) {
						send_error(socket, "invalid name " + name);
						return
					}
					let err = this.game.addPlayer(new Player(name, data.skin, new Vec2(...data.pos)));
					if (err) {
						send_error(socket, err);
						return
					}
					this.playerIds.set(id, name);
					socket.send(JSON.stringify({type: "welcome", tickDuration: tickDuration, world: this.game.viewWorld()}));
				} else if (data.type === "updatePlayer") {
					let name = this.playerIds.get(id);
					if (!name) {
						send_error(socket, "Who the fuck are you?");
						return
					}
					let player = new Player(name, this.game.players.get(name).skin, new Vec2(...data.pos))
					let err = this.game.updatePlayer(player);
					if (err) {
						send_error(socket, err);
					}
				}
			});
		});
	}


	update(delta) {
		this.game.update(delta);
		let data = this.game.view();
		this.broadcast({type: "update", actions: data});
	}

	broadcast(data) {
		for (let socket of this.connections.values()) {
			socket.send(JSON.stringify(data));
		}
	}
}

function send_error(socket, msg) {
	console.warn(msg);
	socket.close(1002, JSON.stringify(msg));
}


main();
