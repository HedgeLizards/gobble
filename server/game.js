

export class Game {

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
