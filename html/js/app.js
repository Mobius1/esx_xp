class XPLeveler {
    constructor(options) {
        const config = {
            xp: 0,
            tick: 100,
            onInit: () => {},
            onChange: () => {},
            onLevelChange: () => {},
            onStart: () => {},
            onEnd: () => {}
        };

        this.config = Object.assign({}, config, options);

        this.init();
    }

    init() {
        this.currentLevel = 1;
        this.currentXP = this.config.xp;
        this.maxLevel = Object.keys(this.config.levels).length;
        this.maxXP = this.config.levels[this.maxLevel];
        this.currentLevel = this.getLevelFromXP();
        this.nextLevel = this.currentLevel + 1;
        this.levelProgress =
            (this.currentXP / this.config.levels[this.nextLevel]) * 100;

        this.previousLevel = 0;
        if (this.currentLevel > 1) {
            this.previousLevel = this.currentLevel - 1;
        }

        this.config.onInit.call(this, this.levelProgress);
    }

    setXP(xp) {
        xp = parseInt(xp, 10);
        if (xp > this.currentXP) {
            this._update(xp - this.currentXP, true);
        } else {
            this._update(this.currentXP - xp, false);
        }
    }

    addXP(xp) {
        xp = parseInt(xp, 10);

        if (this.currentXP >= this.maxXP) {
            xp = 0;
        }

        if (this.currentXP + xp > this.maxXP) {
            xp = this.maxXP - this.currentXP;
        }

        this._update(xp, true);
    }

    removeXP(xp) {
        xp = parseInt(xp, 10);
        if (this.currentXP - xp <= 0) {
            xp = this.currentXP;
        }

        this._update(xp, false);
    }
	
    getLevelFromXP(xp) {
        if ( xp === undefined ) {
            xp = this.currentXP;
        }
		
        const len = Object.keys(this.config.levels).length;
        for (let id in this.config.levels) {
            if (this.config.levels.hasOwnProperty(id)) {
                const level = parseInt(id, 10);

                if (level < len) {
                    if (this.config.levels[level + 1] >= xp) {
                        return level;
                    }
                } else {
                    return level;
                }
            }
        }
    }	

    _update(xp, add) {
		
        if ( this.running ) {
            return false;
        }
		
        xp = parseInt(xp, 10);

        const targetXP = add ? this.currentXP + xp : this.currentXP - xp;
        const levels = this.config.levels;
		
        let level = this.currentLevel;
        let n = this.currentXP;

        this.config.onStart.call(this, add);

        const animate = () => {
            if ((add && n < targetXP) || (!add && n > targetXP)) {
				
                this.running = true;
				
                let levelDiff =
                    this.currentLevel < this.maxLevel
                        ? levels[level + 1] - levels[level]
                        : levels[this.maxLevel] - levels[this.maxLevel - 1];
                const inc = levelDiff / this.config.tick;

                // increment XP
                n += add ? inc : -inc;

                // limit XP
                n = (add && n > targetXP) || (!add && n < targetXP) ? targetXP : n;

                this.currentXP = n;

                // progress bar
                this.levelProgress = ((n - levels[level]) / levelDiff) * 100;
				
                if ( this.levelProgress >= 100 ) {
                    this.levelProgress = 0;
                }

                // indicator bar
                this.maxProgress =
                    targetXP > levels[level + 1]
                        ? 100
                        : 100 * ((targetXP - levels[level]) / levelDiff);
				
                // change callback
                this.config.onChange.call(
                    this,
                    this.levelProgress,
                    this.currentXP,
                    this.maxProgress,
                    add
                );

                // level changed
                if (
                    (add && n >= levels[level + 1] && level < this.maxLevel) ||
                    (!add && n < levels[level] && level > 1)
                ) {
                    const previousLevel = level;
                    let max = false;
                    let levelUp = false;
					
                    // increment / decrement level
                    if (add) {
                        level++;
                        levelUp = true;
                    } else {
                        level--;
                    }
					
                    max = level === this.maxLevel;
					
                    this.currentLevel = level;

                    // new levels
                    if ( !max ) {
                        this.nextLevel = level + 1;
                        this.previousLevel = previousLevel;
                        this.levelProgress = 0;
                    } else {
                        this.levelProgress = 100;
                        this.nextLevel = this.maxLevel;
                        this.previousLevel = this.maxLevel - 1;
                    }

                    // level change callback
                    if (this.previousLevel !== level) {
                        this.config.onLevelChange.call(
                            this,
                            level,
                            this.nextLevel,
                            previousLevel,
                            add,
                            max,
                            levelUp
                        );
                    }
					
                    this.previousLevel = level;
                }

                requestAnimationFrame(animate);
            } else {		
                this.currentXP = targetXP;
				
                this.running = false;

                this.config.onEnd.call(this);
            }
        }

        animate();
    }
}

// Markup
const container = document.querySelector(".xp");
const [ levelA, levelB ] = [...container.querySelectorAll(".xp-level")];
const xpBar = container.querySelector(".xp-progress");
const barA = container.querySelector(".xp-indicator--bar");
const bar = container.querySelector(".xp-progress--bar");
const counter = container.querySelector(".xp-data");
let timer = false;
let initialised = false;

// Create XP bar segments
const segments = 10;
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
    
    if (data.init && !initialised) {
        const levels = {};

        for ( let i = 0; i < data.levels.length; i++ ) {
            levels[i+1] = data.levels[i];
        }

        // Class instance
        instance = new XPLeveler({
            xp: data.xp,
            levels: levels,

            // set initial XP / level
            onInit: function (progress) {
                // create segmented progress bar
                renderBar();

                // fill to starting XP / level
                fillSegments(progress, "lastElementChild");

                // Update level indicators
                levelA.firstElementChild.textContent = this.currentLevel;
                levelB.firstElementChild.textContent = this.nextLevel;
		
                // Update XP counter
                counter.children[0].textContent = this.currentXP;
                counter.children[1].textContent = this.config.levels[this.nextLevel];

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
            onLevelChange: function (current, next, previous, add, max, levelUp) {

                counter.children[1].textContent = this.config.levels[next];
		
                levelB.classList.add("pulse");
		
                fillSegments(0, "firstElementChild");
		
                setTimeout(() => {
                    levelB.classList.remove("pulse");
                    levelA.classList.add("spin");
                    levelB.classList.add("spin");
			
                    levelA.firstElementChild.textContent = current;
                    levelB.firstElementChild.textContent = next;		
			
                    setTimeout(() => {
                        levelA.classList.remove("spin");
                        levelB.classList.remove("spin");
                    }, 500);			
                }, 500);		
            },
	
            onEnd: function (add) {
                // hide the xp bar
                timer = setTimeout(() => {
                    container.classList.remove("active");
                }, 5000);

                xpBar.classList.remove("xp-remove");
            }
        });
    }


    // Set XP
    if (data.set && initialised) {
        instance.setXP(data.xp);
    }

    // Add XP
    if (data.add && initialised) {
        instance.addXP(data.xp);
    }

    // Remove XP
    if (data.remove && initialised) {
        instance.removeXP(data.xp);
    }    
    
    // Show XP bar
    if (data.display && initialised) {
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