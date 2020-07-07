class XPRanker {
    constructor(options) {
        const config = {
            xp: 0,
            tick: 100,
            onInit: () => {},
            onChange: () => {},
            onRankChange: () => {},
            onStart: () => {},
            onEnd: () => {}
        };

        this.config = Object.assign({}, config, options);

        this.init();
    }

    init() {
        this.currentRank = 1;
        this.currentXP = this.config.xp;
        this.maxRank = Object.keys(this.config.levels).length;
        this.maxXP = this.config.levels[this.maxRank];
        this.currentRank = this.getRankFromXP();
        this.nextRank = this.currentRank + 1;
        this.levelProgress =
            (this.currentXP / this.config.levels[this.nextRank]) * 100;

        this.previousRank = 0;
        if (this.currentRank > 1) {
            this.previousRank = this.currentRank - 1;
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
	
    getRankFromXP(xp) {
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
		
        let level = this.currentRank;
        let n = this.currentXP;

        this.config.onStart.call(this, add);

        const animate = () => {
            if ((add && n < targetXP) || (!add && n > targetXP)) {
				
                this.running = true;
				
                let levelDiff =
                    this.currentRank < this.maxRank
                        ? levels[level + 1] - levels[level]
                        : levels[this.maxRank] - levels[this.maxRank - 1];
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
                    (add && n >= levels[level + 1] && level < this.maxRank) ||
                    (!add && n < levels[level] && level > 1)
                ) {
                    const previousRank = level;
                    let max = false;
                    let levelUp = false;
					
                    // increment / decrement level
                    if (add) {
                        level++;
                        levelUp = true;
                    } else {
                        level--;
                    }
					
                    max = level === this.maxRank;
					
                    this.currentRank = level;

                    // new levels
                    if ( !max ) {
                        this.nextRank = level + 1;
                        this.previousRank = previousRank;
                        this.levelProgress = 0;
                    } else {
                        this.levelProgress = 100;
                        this.nextRank = this.maxRank;
                        this.previousRank = this.maxRank - 1;
                    }

                    // level change callback
                    if (this.previousRank !== level) {
                        this.config.onRankChange.call(
                            this,
                            level,
                            this.nextRank,
                            previousRank,
                            add,
                            max,
                            levelUp
                        );
                    }
					
                    this.previousRank = level;
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