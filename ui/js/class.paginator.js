class Paginator {
    constructor(list, perPage) {
        this.list = list;
        this.perPage = perPage;
        this.currentPage = 1;
        this.totalPages = 0;
        this.lastPage = 0;
    }
	
    paginate() {
        const keys = Object.keys(this.list);
        this.pages = keys
            .map((tr, i) => {
                return i % this.perPage === 0 ? keys.slice(i, i + this.perPage) : null;
            })
            .filter(function (page) {
                return page;
            });

        this.totalPages = this.lastPage = this.pages.length;		
    }

    setPerPage(perPage) {
        this.perPage = perPage;

        this.paginate();     
    }
	
    addItem(item) {
        this.list[item.id] = item;
		
        this.paginate();
    }
	
    addItems(items) {
        for ( id  in items ) {
            this.list[id] = items[id];
        }
		
        this.paginate();
    }
}
