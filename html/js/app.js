// Markup
const container = document.querySelector(".xp");
const inner = document.querySelector(".xp-inner");
const [ levelA, levelB ] = [...container.querySelectorAll(".xp-level")];
const xpBar = container.querySelector(".xp-progress");
const barA = container.querySelector(".xp-indicator--bar");
const bar = container.querySelector(".xp-progress--bar");
const counter = container.querySelector(".xp-data");
let timer = false;
let initialised = false;

// Create XP bar segments
let segments = 10;
let instance = false;

// HELPER FUNCTIONS
function renderBar() {
    const frag = document.createDocumentFragment();
    for (let i = 0; i < segments; i++) {
        const div = document.createElement("div");
        div.classList.add("xp-segment");
        div.innerHTML = `<div class="xp-indicator--bar"></div><div class="xp-progress--bar"></div>`;

        frag.appendChild(div);
    }

    xpBar.appendChild(frag);
}

function fillSegments(pr, child) {
    const p = (segments / 100) * pr;
    const filled = Math.floor(p);
    const partial = p % 1;

    for (let i = 0; i < segments; i++) {
        if (i + 1 <= filled) {
            xpBar.children[i][child].style.width = "100%";
        } else {
            xpBar.children[i][child].style.width = "0%";
        }

        if (i + 1 === filled + 1) {
            xpBar.children[i][child].style.width = `${partial * 100}%`;
        }
    }
}


window.onData = function (data) {
    
    if (data.esxp_init && !initialised) {

        const levels = {};

        for ( let i = 0; i < data.esxp_config.Ranks.length; i++ ) {
            levels[i+1] = data.esxp_config.Ranks[i];
        }

        // Class instance
        instance = new XPRanker({
            xp: data.xp,
            levels: levels,

            // set initial XP / level
            onInit: function (progress) {

                segments = data.esxp_config.BarSegments

                // create segmented progress bar
                renderBar();

                inner.style.width = `${data.esxp_config.Width}px`;

                clearTimeout(timer);
                // show the xp bar
                container.classList.add("active");     
                
                // hide the xp bar
                timer = setTimeout(() => {
                    container.classList.remove("active");
                }, data.esxp_config.Timeout);                

                // fill to starting XP / level
                fillSegments(progress, "lastElementChild");

                // Update level indicators
                levelA.firstElementChild.textContent = this.currentRank;
                levelB.firstElementChild.textContent = this.nextRank;
		
                // Update XP counter
                counter.children[0].textContent = this.currentXP;
                counter.children[1].textContent = this.config.levels[this.nextRank];

                initialised = true;
            },
	
            onStart: function(add) {
                clearTimeout(timer);
                // show the xp bar
                container.classList.add("active");

                // make segments red if removing XP
                xpBar.classList.toggle("xp-remove", !add);
            },

            // Update XP progress
            onChange: function (progress, xp, max, add) {
                // update progress bar
                fillSegments(progress, "lastElementChild");
		
                // update indicator bar
                fillSegments(max, "firstElementChild");

                // update xp counter
                counter.children[0].textContent = xp;
            },

            // Update on level change
            onRankChange: function (current, next, previous, add, max, levelUp) {

                counter.children[1].textContent = this.config.levels[next];
		
                levelB.classList.add("pulse");
		
                fillSegments(0, "firstElementChild");
		
                setTimeout(() => {
                    levelB.classList.remove("pulse");
                    levelA.classList.add("spin");
                    levelA.classList.add("highlight");
                    levelB.classList.add("spin");
                    levelB.classList.add("highlight");
			
                    levelA.firstElementChild.textContent = current;
                    levelB.firstElementChild.textContent = next;		
			
                    setTimeout(() => {
                        levelA.classList.remove("spin");
                        levelA.classList.remove("highlight");
                        levelB.classList.remove("spin");
                        levelB.classList.remove("highlight");
                    }, 500);			
                }, 500);			
            },
	
            onEnd: function (add) {
                // hide the xp bar
                timer = setTimeout(() => {
                    container.classList.remove("active");
                }, data.esxp_config.Timeout);

                xpBar.classList.remove("xp-remove");
            }
        });
    }


    // Set XP
    if (data.esxp_set && initialised) {
        instance.setXP(data.xp);
    }

    // Add XP
    if (data.esxp_add && initialised) {
        instance.addXP(data.xp);
    }

    // Remove XP
    if (data.esxp_remove && initialised) {
        instance.removeXP(data.xp);
    }    
    
    // Show XP bar
    if (data.esxp_display && initialised) {
        container.classList.add("active");

        this.clearTimeout(this.xpTimer);

        this.xpTimer = this.setTimeout(() => {
            container.classList.remove("active");
        }, 5000);
    }    
};

window.onload = function (e) {
    window.addEventListener('message', function (event) {
        onData(event.data);
    });
};