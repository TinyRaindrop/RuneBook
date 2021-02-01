const rp = require('request-promise-native');
const {
    sortRunes
} = require('./utils');

// #region U.GG API consts
const u = {
    positions: {
        jungle: 1,
        support: 2,
        adc: 3,
        top: 4,
        mid: 5,
        none: 6
    },
    positionsReversed: {
        1: 'Jungle',
        2: 'Support',
        3: 'ADC',
        4: 'Top',
        5: 'Mid',
        6: ''
    },
    tiers: {
        challenger: 1,
        master: 2,
        diamond: 3,
        platinum: 4,
        gold: 5,
        silver: 6,
        bronze: 7,
        overall: 8,
        platPlus: 10,
        diaPlus: 11
    },
    servers: {
        na: 1,
        euw: 2,
        kr: 3,
        eune: 4,
        br: 5,
        las: 6,
        lan: 7,
        oce: 8,
        ru: 9,
        tr: 10,
        jp: 11,
        world: 12
    },
    stats: {
        perks: 0,
        statShards: 8
    },
    perks: {
        games: 0,
        won: 1,
        mainPerk: 2,
        subPerk: 3,
        perks: 4
    },
    shards: {
        games: 0,
        won: 1,
        stats: 2
    }
};
// #endregion

// #region Settings
const supported_modes = [{
        key: "ranked_solo_5x5",
        name: "Ranked",
        tier: u.tiers.platPlus
    },
    {
        key: "normal_aram",
        name: "ARAM",
        tier: u.tiers.overall
    }
];

const baseOverviewUrl = `https://stats2.u.gg/lol`;
const statsVersion = "1.1";
const overviewVersion = "1.4.0";
const usedServer = u.servers.world;
// #endregion

/**
 * Get the Overview-JSON from the U.GG-API.
 * 
 * @param {number} championId Id of the champion for which the data should be determined.
 * @param {string} gameMode The game mode for which the rune pages should be determined.
 * @returns The full Overview-JSON for the champion in the specified game mode.
 */
async function getOverviewJsonAsync(championId, gameMode) {
    // Try the last two LOL versions (this is necessary because U.GG is currently updating with a delay on Patch-Day)
    for (const lolVersion of freezer.get().lolversions.slice(0, 2)) {
        // Convert LOL version into a format suitable for U.GG
        const uggLoLVersion = lolVersion.split('.').splice(0, 2).join('_');

        // Create URL based on the parameters
        const requestUri = `${baseOverviewUrl}/${statsVersion}/overview/${uggLoLVersion}/${gameMode}/${championId}/${overviewVersion}.json`;

        // Query URL and get the result
        var result = await rp({
            uri: requestUri,
            json: true
        })
        .then(function(response) {
            return response;
        })
        .catch(function(err) {
            if(err.statusCode === 403)
                console.log("JSON was not found => " + err);
            else
                throw Error("Error when determining json => " + err);  
        });

        // is there a result? => return result
        if(result)
            return result
    }

    // fallback
    return null;
}

/**
 * Returns a rune page based on the JSON and with the given data.
 * 
 * @param {string} runesJson U.GG JSON that is being processed.
 * @param {string} champion Name of the champion for which the page should be determined.
 * @param {number} position Position for which the page should be determined.
 * @param {string} gameMode The game mode for which the rune page should be determined.
 * @returns A rune page matches the given parameters.
 */
function getPage(runesJson, champInfo, position, gameMode) {
    try {
        // Break Json down to the position and data
        const runesJsonModed = runesJson[position][0];

        // Break Json down to the perks data and stat shards
        const perksData = runesJsonModed[u.stats.perks];
        const statShards = runesJsonModed[u.stats.statShards][u.shards.stats].map(str => parseInt(str, 10));

        // Determine selected perk ids
        const selectedPerkIds = sortRunes(perksData[u.perks.perks]).concat(statShards);

        // Return rune page
        return {
            name: `[${gameMode.name}] ${champInfo.name} ${u.positionsReversed[position]}`.trim(),
            selectedPerkIds: selectedPerkIds,
            bookmark: {
                champId: champInfo.id,
                gameModeKey: gameMode.key,
                position: position,
                remote: {
                    name: plugin.name,
                    id: plugin.id
                }
            }
        };
    } catch (e) {
        throw Error(e);
    }
}

/**
 * Determines all possible rune pages for a given champion for the specified game mode.
 * 
 * @param {string} champion Name of the champion for which the pages should be determined.
 * @param {string} gameMode The game mode for which the rune pages should be determined.
 * @param {number} force_position Returns the position to which the data is to be returned. In case of NULL all are returned.
 * @returns all possible rune pages for a particular champion for the specified game mode.
 */
async function getPagesForGameModeAsync(champInfo, gameMode, force_position = null) {
    // Return variable (List of rune pages)
    var returnVal = [];

    try {
        // get json for the given champ and game mode
        var result = await getOverviewJsonAsync(champInfo.key, gameMode.key);

        // if a result was found, parse it and add it to the return
        if (result) {
            // reduce returns by server and tier (json includes all servers and tiers)
            result = result[usedServer][gameMode.tier];

            // check if a certain position was selected. If not all are returned
            if (force_position) {
                // add only the rune page for the selected position
                returnVal.push(getPage(result, champInfo, force_position, gameMode));
            } else {
                // run through all positions
                for (const position of Object.keys(result)) {
                    returnVal.push(getPage(result, champInfo, position, gameMode));
                }
            }
        }
    } catch (e) {
        throw Error(e);
    }

    // Return list of the rune page
    return returnVal;
}

/**
 * Determines all possible rune pages for a particular champion for all supported game modes.
 * 
 * @param {string} champion Id of the champion for which the pages should be determined.
 * @param callback callback which is called for the return of the data.
 * @returns all possible rune pages for a particular champion for all supported game modes.
 */
async function _getPagesAsync(champion, callback) {
    const runePages = {
        pages: {}
    };

    // Determine champion information based on the name
    const champInfo = freezer.get().championsinfo[champion];

    try {
        // go through all supported game modes
        for (const gameMode of supported_modes) {
            // determine rune pages for the respective game mode and add them to the return
            for (const runePage of await getPagesForGameModeAsync(champInfo, gameMode)) {
                runePages.pages[runePage.name] = runePage;
            }
        }

        // sort rune pages based on the key (name)
        const ordered = {};
        Object.keys(runePages.pages).sort().forEach(function(key) {
            ordered[key] = runePages.pages[key];
        });
        runePages.pages = ordered;

        // return rune pages
        callback(runePages);
    } catch (e) {
        // In case of error, return all rune pages determined up to this point
        callback(runePages);
        throw Error(e);
    }
}

/**
 * It averages a special rune page based on the given parameters to update the bookmark.
 * 
 * @param {string} champId Id of the champion for which the rune page should be determined.
 * @param {number} position Position for which the rune page should be determined.
 * @param {string} gameModeKey Key of the game mode for which the rune page should be determined.
 * @param callback callback which is called for the return of the data.
 */
async function _syncBookmarkAsync(champId, position, gameModeKey, callback) {
    try {
        // Determine champion information based on the name
        const champInfo = freezer.get().championsinfo[champId];

        // Determine game mode on the basis of the key
        const gameMode = supported_modes.filter(i => i.key == gameModeKey)[0];

        // determine all pages for the selected game mode and position
        const pages = await getPagesForGameModeAsync(champInfo, gameMode, position);

        // return rune page
        callback(pages[0]);
    } catch (e) {
        // If there is an error still callback so the UI does not hang
        callback();
        throw Error(e);
    }
}

// #region Plugin-Funktionen
var plugin = {
    id: "ugg",
    name: "U.GG",
    active: true,
    bookmarks: true,

    getPages(champion, callback) {
        // Find all rune pages
        _getPagesAsync(champion, callback);
    },
    syncBookmark(bookmark, callback) {
        // Find and update a rune page based on the bookmark
        _syncBookmarkAsync(bookmark.champId, bookmark.position, bookmark.gameModeKey, callback);
    }
};

module.exports = {
    plugin
};
// #endregion