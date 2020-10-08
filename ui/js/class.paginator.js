class Paginator {
    constructor(perPage, sortBy) {
        this.list = {};
        this.perPage = perPage;
        this.sortBy = sortBy;
        this.currentPage = 1;
        this.totalPages = 0;
        this.lastPage = 0;
    }

    paginate(order) {
        if (order === undefined) {
            order = this.sortBy;
        }

        const list = Object.values(this.list);

        this.pages = list.sort((a, b) => {
                if (order === "rank") {
                    if (a.rank < b.rank) {
                        return 1;
                    } else if (a.rank > b.rank) {
                        return -1;
                    }
                } else if (order === "name") {
                    if (a.name.toLowerCase() > b.name.toLowerCase()) {
                        return 1;
                    } else if (a.name.toLowerCase() < b.name.toLowerCase()) {
                        return -1;
                    }
                }

                return 0;
            })
            .map((item, i) => {
                return i % this.perPage === 0 ? list.slice(i, i + this.perPage) : null;
            }).filter(page => page);

        this.totalPages = this.lastPage = this.pages.length;
    }

    setPerPage(perPage) {
        this.perPage = perPage;

        this.paginate();
    }

    addItem(item) {
        this.list[item.id] = item;
    }

    addItems(items) {
        for (id in items) {
            this.list[id] = items[id];
        }

        this.paginate();
    }
}