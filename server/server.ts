import { type AddressInfo, WebSocket, WebSocketServer } from 'ws';
import { create } from 'superstruct';
import { Game } from './game.js';
import { ClientMessage, ServerMessage, ActionMessage} from './messages.js';
import { createServer } from 'https';
import { readFileSync } from 'fs';


const tickDuration = 0.1;

type Args = {port: number, tls?: {key: string, cert: string}};

function parseArgs(): Args {
	let argv = process.argv.slice(2);
	let args: Args = {
		port: 9412,
	}
	let i: number = 0;
	while (i < argv.length) {
		let a: string = argv[i++].trim();
		if (a === "-p" || a === "--port") {
			if (i >= argv.length) throw new Error("missing argument for "+a);
			args.port = parseInt(argv[i++].trim());
		} else if (a === "-s" || a === "--tls") {
			if (i+1 >= argv.length) throw new Error("missing argument for "+a);
			let cert = argv[i++].trim();
			let key = argv[i++].trim();
			args.tls = {cert, key};
		} else {
			throw new Error(`Unknown argument '${a}'`);
		}
	}
	return args;
}

function main() {
	let args = parseArgs();
	let game = new Game()
	let server = new Serv(game, args);
	setInterval(() => server.update(tickDuration), tickDuration * 1000);
}


class Serv {
	game: Game
	playerIds: Map<number, string>
	connections: Map<number, WebSocket>
	nextId: number
	wss: WebSocketServer

	constructor(game: Game, args: Args) {
		this.game = game;
		this.playerIds = new Map();
		this.connections = new Map();
		this.nextId = 1;
		if (args.tls) {
			let server = createServer({
				cert: readFileSync(args.tls.cert),
				key: readFileSync(args.tls.key),
			});
			this.wss = new WebSocketServer({server});
			server.listen(args.port);
		} else {
			this.wss = new WebSocketServer({port: args.port});
		}
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
					let err = this.game.addPlayer(data.id, data);
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
				} else if (data.type === "createBuilding") {
					if (!this.game.addBuilding(data.cost, data.kind, data.pos)) {
						return;
					}
					let response: ActionMessage = {
						type: "buildingCreated",
						kind: data.kind,
						pos: data.pos,
						gold: this.game.gold,
					};
					this.broadcast({type: "update", actions: [response]});
				} else if (data.type === "buyGun") {
					if (data.cost > this.game.gold) {
						return;
					};
					this.game.gold -= data.cost;
					let response: ActionMessage = {
						type: "gunBought",
						buyerId: data.buyerId,
						weapon: data.weapon,
						gold: this.game.gold,
					};
					this.broadcast({type: "update", actions: [response]});
				} else if (data.type === "emptyBank") {
					const building = this.game.grid[data.pos.y][data.pos.x];
					if (building?.kind === "Bank" && building.interest > 0) {
						building.interest = -building.interest;
					}
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
