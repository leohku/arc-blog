import { Space, SidebarNode, SidebarNodeType } from "@/types/space";

export type Resolved =
  | {
      found: true;
      result: {
        type: SidebarNodeType;
        info: string;
      };
    }
  | {
      found: false;
    };

export default function resolve(slugArray: string[], space: Space): Resolved {
  return _resolve(slugArray, space.pinned.concat(space.unpinned));
}

function _resolve(slugArray: string[], searchSpace: SidebarNode[]): Resolved {
  if (slugArray.length === 0) {
    return {
      found: false,
    };
  }
  const [slug, ...remainingSlugs] = slugArray;
  if (remainingSlugs.length === 0) {
    for (let node of searchSpace) {
      if (node.type !== SidebarNodeType.List && slug === node.title) {
        return {
          found: true,
          result: {
            type: node.type,
            info: (() => {
              switch (node.type) {
                case SidebarNodeType.Tab:
                  return node.url || "";
                case SidebarNodeType.ArcDocument:
                  return node.documentId || "";
                case SidebarNodeType.Easel:
                  return node.easelId || "";
                default:
                  return "";
              }
            })(),
          },
        };
      }
    }
    return { found: false };
  } else {
    for (let node of searchSpace) {
      switch (node.type) {
        case SidebarNodeType.List:
          if (slug === node.title) {
            let tmp = _resolve(remainingSlugs, node.children || []);
            if (tmp.found) {
              return tmp;
            }
          }
          break;
        case SidebarNodeType.ItemContainer:
        case SidebarNodeType.SplitView:
          let tmp = _resolve(remainingSlugs, node.children || []);
          if (tmp.found) {
            return tmp;
          }
      }
    }
    return { found: false };
  }
}
