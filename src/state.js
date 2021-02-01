var Freezer = require('freezer-js');

var state = {
	session: {
		connected: false,
		state: ""
	},

	connection: {
		page: null,
		summonerLevel: 0
	},

	current: {
		champion: null,
		champ_data: {
			fav: null,
			pages: {},
		},
	},

	favChampions: [
		{name: "Vi"},
		{name: "Trundle"},
		{name: "Zyra"},
		{name: "Leona"},
		{name: "Morgana"},
	],

	tab: {
		active: "local",
		loaded: true,
	},

	lastuploadedpage: {
		champion: null,
		page: null,
		valid: false,
		loading: false
	},

	lastbookmarkedpage: {
		champion: null,
		page: null
	},

	lastsyncedpage: {
		champion: null,
		page: null,
		loading: false
	},

	plugins: {},

	updateready: false,

	lang: 'en',

	minimizetotray: false,

	configfile: {
		name: "config.json",
		cwd: "[default path]"
	},

	// we could cache this information
	championsinfo: {},
	runesreforgedinfo: [],

	lolversions: [],

	champselect: {
		active: false,
		gameMode: null,
		favUploaded: false,
	},
	autochamp: false,

	tooltips: {
		rune: null
	},

	showchangelog: false,
	changelogbody: ''
};

module.exports = new Freezer(state);