
import { Player } from "./player.js";

export class Game {

	constructor(){
		this.players = new Map();
		this.removed = [];
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
		this.removed.push(name);
		this.players.delete(name);
	}

	view() {
		let actions = [];
		for (let removed of this.removed) {
			actions.push({type: "playerDeleted", id: removed});
		}
		this.removed = []
		for (let player of this.players.values()){
			actions.push(player.view());
		}
		return actions;
	}
}
