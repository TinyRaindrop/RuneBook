const rp = require('request-promise-native');
const { groupBy } = require('lodash');

/**
 * Gets a JSON object from a URI via 'request-promise-native'.
 * @param {string} uri - URI from which the json is to be retrieved
 * @return {object} JSON object what were received from the uri
 */
function getJson(uri) {
  return rp({ uri, json: true });
}

/**
 * Returns a list of runes styles with ID as value.
 * @param {string} usedKeyStr - The value to be used as key. Default is 'name'
 * @return {object} A list of rune styles with the respective ID as value.
 */
function getStylesMap(usedKeyStr = 'name') {
  const stylesMap = {};

  freezer.get().runesreforgedinfo.forEach(runeInfo => {
    stylesMap[runeInfo[usedKeyStr]] = runeInfo.id;
  });

  return stylesMap;
}

/**
 * Returns a list of rune perks with ID as value.
 * @param {string} usedKeyStr - The value to be used as key. Default is 'name'
 * @return {object} A list of rune perks with the respective ID as value.
 */
function getPerksMap(usedKeyStr = 'name') {
  const perksMap = {};

  freezer.get().runesreforgedinfo.forEach(runeInfo => {
    [].concat(...runeInfo.slots.map(row => row.runes)).forEach(rune => {
      perksMap[rune[usedKeyStr]] = rune.id;
    });
  });

  return perksMap;
}

/**
 * Sorts the runes as they are in the game.
 * @param {Array} runes - A list of runes ids
 * @return {Array} Sorted list of runes
 */
function sortRunes(runes) {
  // Index map for later sorting
  const indexes = new Map();

  // Sorting function that sorts the runes based on the index in the tree
  const sortingFunc = (a, b) => indexes.get(a) - indexes.get(b);

  // Creates a tree of style id and the matching runes
  const tree = freezer.get().runesreforgedinfo.reduce((obj, curr) => {
    obj[curr.id] = [].concat(...curr.slots.map(row => row.runes.map(i => i.id)));
    return obj;
  }, {});

  // Creates a list of style ids based on the tree
  const styleIds = Object.keys(tree).map(Number);

  // Filters style ids from the runes
  const filteredRunes = runes.filter(rune => !styleIds.includes(rune));

  // Groups the passed runes fit to the respective style id
  const groupedRunes = groupBy(filteredRunes, (rune) => {
    for (const style of styleIds) {
      const runeIndex = tree[style].indexOf(rune);
      if (runeIndex !== -1) {
        indexes.set(rune, runeIndex);
        return style;
      }
    }
  });

  // Variables for determining the 'primaryStyleId' and 'secondaryStyleId
  let primaryStyleLength = -1;
  let primaryStyleId = -1;
  let secondaryStyleLength = -1;
  let secondaryStyleId = -1;

  // Get 'primaryStyleId' and 'secondaryStyleId' based on the number of runes
  for (const styleId in groupedRunes) {
    if(styleId !== 'undefined'){
      if(groupedRunes[styleId].length > primaryStyleLength){
        secondaryStyleId = primaryStyleId;
        primaryStyleId = styleId;
        primaryStyleLength = groupedRunes[styleId].length;
      }else if(groupedRunes[styleId].length >= secondaryStyleLength){
        secondaryStyleId = styleId;
        secondaryStyleLength = groupedRunes[styleId].length;
      }
    }
  }

  // Sorts the groups for the respective style
  groupedRunes[primaryStyleId].sort(sortingFunc);
  groupedRunes[secondaryStyleId].sort(sortingFunc);

  // Merges primary and secondary runes in the correct order
  return groupedRunes[primaryStyleId].concat(groupedRunes[secondaryStyleId], groupedRunes['undefined'] ?? []);
}

// Transfer of functions for use in other modules
module.exports = { getStylesMap, getPerksMap, getJson, sortRunes };
