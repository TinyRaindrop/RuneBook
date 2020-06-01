var Store = require('electron-store');
var settings = require('../src/settings');

var configPath = settings.get("config.cwd");
var configName = settings.get("config.name");

console.log("configName", configName);
console.log("configPath", configPath);

var store = new Store({cwd: configPath, name: configName});

var plugin = {
	name: "chapters.localpages",
	local: true,
	active: true,

	getPages(champion, callback) {
		var res = store.get(`local.${champion}`) || {pages: {}};
		callback(res);
	},

	favPage(champion, pagename) {
		if(store.get(`local.${champion}.fav`) == pagename) {
			store.set(`local.${champion}.fav`, null);
		}
		else store.set(`local.${champion}.fav`, pagename);
	},

	deletePage(champion, pagename) {
		console.log(champion, pagename)
		pagename = pagename.replace(/\./g, '\\.');
		store.delete(`local.${champion}.pages.${pagename}`);
		if(store.get(`local.${champion}.fav`) == pagename) {
			store.set(`local.${champion}.fav`, null);
		}
	},

	unlinkBookmark(champion, pagename) {
		pagename = pagename.replace(/\./g, '\\.');
		store.delete(`local.${champion}.pages.${pagename}.bookmark`);
	},

	savePage(champion, page) {
		var pagename = page.name.replace(/\./g, '\\.');
		store.set(`local.${champion}.pages.${pagename}`, page);
	},

	saveAllPages(champion, pages) {
		store.set(`local.${champion}.pages`, pages);
	},

	confirmPageValidity(champion, pagename, res) {
		pagename = pagename.replace(/\./g, '\\.');
		/*
		 * If the page returned is invalid, mark it as such in the store.
		 * This behaviour is not predictable (a page can become invalid at any time),
		 * so we want to make sure to notify users as soon as we get this info from lcu.
		 */
		if(res.isValid === false) {
			console.log("Warning: page incomplete or malformed.");
			store.set(`local.${champion}.pages.${pagename}.isValid`, false);
		}
		/*
		 * If the page returned is valid, but we have an invalid copy in the store,
		 * then replace the local page with the updated one.
		 */
		else if(store.get(`local.${champion}.pages.${pagename}.isValid`) === false) {
			store.set(`local.${champion}.pages.${pagename}`, res);
		}
	}
}

module.exports = { plugin };