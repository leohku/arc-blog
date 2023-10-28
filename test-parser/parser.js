const fs = require("fs");
const path = require("path");

const itemSearch = (id) => {
  for (let i = 0; i < sidebar.items.length; i = i + 2) {
    if (sidebar.items[i] === id) {
      return sidebar.items[i + 1];
    }
  }
};

const buildTree = (id) => {
  let node = {};
  const item = itemSearch(id);
  node.id = item.id;
  node.type = (() => {
    if ("tab" in item.data) return "tab";
    if ("arcDocument" in item.data) return "arcDocument";
    if ("easel" in item.data) return "easel";
    if ("list" in item.data) return "list";
    if ("itemContainer" in item.data) return "itemContainer";
    throw "node type not supported: " + JSON.stringify(item);
  })();
  switch (node.type) {
    case "tab":
      node.title = item.title || item.data.tab.savedTitle;
      node.url = item.data.tab.savedURL;
      break;
    case "arcDocument":
      node.title = item.title;
      node.documentId = item.data.arcDocument.arcDocumentID;
      break;
    case "easel":
      node.title = item.title || item.data.easel.title;
      node.easelId = item.data.easel.easelID;
      break;
    case "list":
      node.title = item.title;
      node.children = item.childrenIds.map((childrenId) =>
        buildTree(childrenId)
      );
      break;
    case "itemContainer":
      node.children = item.childrenIds.map((childrenId) =>
        buildTree(childrenId)
      );
      break;
    default:
      throw "node type not handled: " + node.type;
  }
  return node;
};

const buildForest = (id) => {
  const item = itemSearch(id);
  return item.childrenIds.map((childrenId) => buildTree(childrenId));
};

const filePath = path.join(__dirname, "StorableSidebar.json");
const sidebarJson = JSON.parse(fs.readFileSync(filePath, "utf-8"));
const sidebar = sidebarJson.sidebar.containers[1];
const output = [];

for (const space of sidebar.spaces) {
  if (typeof space === "string") {
    continue;
  }
  const spaceObject = {};
  spaceObject.id = space.id;
  spaceObject.title = space.title;
  spaceObject.profile = (() => {
    if ("default" in space.profile) {
      return {
        default: true,
      };
    } else {
      return {
        default: false,
        directoryBasename: space.profile.custom._0.directoryBasename,
      };
    }
  })();
  spaceObject.topApps = (() => {
    let topAppsContainerID;
    for (let i = 0; i < sidebar.topAppsContainerIDs.length; i++) {
      if (typeof sidebar.topAppsContainerIDs[i] === "string") {
        continue;
      }
      if (spaceObject.profile.default) {
        if ("default" in sidebar.topAppsContainerIDs[i]) {
          topAppsContainerID = sidebar.topAppsContainerIDs[i + 1];
          break;
        }
      } else {
        if (
          "custom" in sidebar.topAppsContainerIDs[i] &&
          spaceObject.profile.directoryBasename ===
            sidebar.topAppsContainerIDs[i].custom._0.directoryBasename
        ) {
          topAppsContainerID = sidebar.topAppsContainerIDs[i + 1];
          break;
        }
      }
    }
    return buildForest(topAppsContainerID);
  })();
  spaceObject.unpinned =
    typeof space.containerIDs[1] !== "undefined"
      ? buildForest(space.containerIDs[1])
      : [];
  spaceObject.pinned =
    typeof space.containerIDs[3] !== "undefined"
      ? buildForest(space.containerIDs[3])
      : [];

  output.push(spaceObject);
}

console.log(JSON.stringify(output));
