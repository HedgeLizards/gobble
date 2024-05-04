import { type AddressInfo, WebSocket, WebSocketServer } from 'ws';
import { create } from 'superstruct';
import { Game } from './game.js';
import { ClientMessage, ServerMessage, ActionMessage} from './messages.js';


const tickDuration = 0.1

function main() {
	let port: number = 9412
	if (process.argv.length >= 3) {
		port = Number.parseInt(process.argv[2]);
	}
	let game = new Game()
	let server = new Serv(game, port);
	setInterval(() => server.update(tickDuration), tickDuration * 1000);
}


class Serv {
	game: Game
	playerIds: Map<number, string>
	connections: Map<number, WebSocket>
	nextId: number
	wss: WebSocketServer

	constructor(game: Game, port: number) {
		this.game = game;
		this.playerIds = new Map();
		this.connections = new Map();
		this.nextId = 1;
		this.wss = new WebSocketServer({port: port});
		this.wss.once('listening', () => console.log(`Listening on port ${(this.wss.address() as AddressInfo).port}`));
		this.wss.on("connection", socket => {
			let id = this.nextId++;
			this.connections.set(id, socket);
			socket.on("close", (code, msg) => {

				this.connections.delete(id);
				let playerName = this.playerIds.get(id);
				if (playerName) {
					console.log("Player left ", playerName, code, msg);
					console.log("msg", JSON.stringify(msg));
					this.game.removePlayer(playerName);
				}
			});
			socket.on("error", error => {

				this.connections.delete(id);
				let playerName = this.playerIds.get(id);
				if (playerName) {
					console.log("Player errored", playerName, error.toString());
					console.log("msg", JSON.stringify(error));
					this.game.removePlayer(playerName);
				}
			});
			socket.on("message", msg => {
				if (socket.readyState === WebSocket.CLOSING) {
					return;
				}
				let rawData = JSON.parse(msg.toString());
				let data: ClientMessage;
				try {
					data = create(rawData, ClientMessage);
				} catch (e) {
					console.error("invalid message structure: ", e)
					send_error(socket, `Incorrect structure for ${rawData.type}: ${msg.toString()}`);
					return;
				}
				if (data.type === "createPlayer") {
					if (this.playerIds.has(id)) {
						send_error(socket, "Can only introduce once");
						return;
					}
					if (!(data.name.toLowerCase() === data.id.substring(2))) {
						send_error(socket, `id '${data.id}' does not match name '${data.name}'`);
						return;
					}
					let err = this.game.addPlayer(data.id, data);//data.skin, data.pos, data.aim, data.weapon, data.health || 100, data.maxhealth || 100));
					if (err) {
						send_error(socket, err);
						return;
					}
					this.playerIds.set(id, data.id);
					let welcome: ServerMessage = {type: "welcome", tickDuration: tickDuration, world: this.game.viewWorld()}
					socket.send(JSON.stringify(welcome));
				} else if (data.type === "updatePlayer") {
					let name = this.playerIds.get(id);
					if (!name) {
						send_error(socket, "Who the fuck are you?");
						return
					}
					let player = this.game.getPlayer(name);
					if (!player) {
						send_error(socket, "unknown player " + name);
					} else {
						player.update(data);
					}
				} else if (data.type === "createProjectiles") {
					let responses: ActionMessage[] = []
					for (let projectile of data.projectiles) {
						responses.push({
							type: "projectileCreated",
							creatorId: data.creatorId,
							isEnemy: data.isEnemy,
							weapon: data.weapon,
							...projectile,
						});
					}
					this.broadcast({type: "update", actions: responses});
				} else if (data.type === "impactProjectile") {
					for (const impactedId of data.impactedIds) {
						game.hitEntity(impactedId, data.damage);
					}
					let response: ActionMessage = {
						...data,
						type: "projectileImpacted",
					};
					this.broadcast({type: "update", actions: [response]});
				}
			});
		});
	}


	update(delta: number) {
		let actions: ActionMessage[] = this.game.update(delta);
		this.broadcast({type: "update", actions: actions});
	}

	broadcast(data: ServerMessage) {
		for (let socket of this.connections.values()) {
			socket.send(JSON.stringify(data));
		}
	}
}

function send_error(socket: WebSocket, msg: string) {
	console.warn("Player error", msg);
	if (msg.length > 120) {
		msg = msg.substring(0, 117) + "...";
	}
	socket.close(1002, msg);
}


main();
