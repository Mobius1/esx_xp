class Leaderboard {
    constructor(options) {

        const config = {
            showPing: false
        };

        this.config = Object.assign({}, config, options);

        this.container = document.getElementById("xpm_leaderboard");
        this.players = {};
		
        this.init();
    }
	
    init() {
        this.inner = document.createElement("div");
        this.inner.classList.add("xpm-leaderboard--inner")
		
        this.header = document.createElement("div");
        this.header.classList.add("xpm-leaderboard--header");
		
        this.list = document.createElement("ul");
        this.list.classList.add("xpm-leaderboard--players");
		
        this.inner.appendChild(this.header);
        this.inner.appendChild(this.list);
    }
	
    render() {
        this.container.appendChild(this.inner);
    }
	
    addPlayer(player) {
        const li = document.createElement("li");
        li.classList.add("xpm-leaderboard--player");
		
        const info = document.createElement("div");
        info.classList.add("xpm-leaderboard--playerinfo");
		
        const name = document.createElement("div");
        name.classList.add("xpm-leaderboard--playername");	
		
        const rank = document.createElement("div");
        rank.classList.add("xpm-leaderboard--playerrank");
		
        const num = document.createElement("div");
        num.classList.add("xpm-leaderboard--playerranknum");
		
        name.textContent = player.name;
        num.textContent = player.rank;
		
        const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.innerHTML = `<g>
                            <circle cx="552.13" cy="551.577" r="512" />
                            <line x1="66.298" y1="713.576" x2="1037.962" y2="713.576" />
                            <line x1="1037.962" y1="389.577" x2="66.298" y2="389.577" />
                            <path d="M721.313,1034.963c50.182-119.717,81.658-291.957,81.658-483.386
        c0-191.43-31.477-363.671-81.658-483.387" />
                            <path d="M382.945,68.192c-50.181,119.716-81.656,291.957-81.656,483.384
        c0,191.427,31.476,363.666,81.655,483.382" />
                        </g>`;
		
        svg.setAttribute("viewBox", "0 0 1104 1104");
		
        rank.appendChild(svg);
        rank.appendChild(num);
		
        info.appendChild(name);

        if ( this.config.showPing ) {
            const ping = document.createElement("div");
            ping.classList.add("xpm-leaderboard--playerping");

            ping.textContent = `${player.ping}ms`;

            info.appendChild(ping);
        }

        li.appendChild(info);
        li.appendChild(rank);
		
        this.list.appendChild(li);
		
        player.row = li;
		
        this.players[player.id] = player;
		
        this.header.textContent = `Players: ${this.getPlayerCount()}`;
    }

    updatePlayers(players) {

        this.list.innerHTML = "";
        this.players = {};

        for ( const player of players ) {
            this.addPlayer(player);
        }

        this.header.textContent = `Players: ${this.getPlayerCount()}`;
    }

    getPlayerCount() {
        return Object.keys(this.players).length;
    }
	
    addPlayers(players) {
        for ( const player of players ) {
            if ( !(player.id in this.players) ) {
                this.addPlayer(player);
            }
        }
    }

    removePlayer(player) {
        if ( player.id in this.players ) {
            this.list.removeChild(this.players[player.id].row);

            delete this.players[player.id];
        }
    }

    removePlayers(players) {
        for ( const id in players ) {
            const player = players[id];

            if ( player.id in this.players ) {
                this.list.removeChild(this.players[player.id].row);

                delete this.players[player.id];
            }
        }
    }

    updateRank(id, rank) {
        if ( id in this.players ) {
            this.players[id].rank = rank;
            this.players[id].row.querySelector(".xpm-leaderboard--playerranknum").textContent = rank;
        }
    }    
}