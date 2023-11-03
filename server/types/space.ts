export interface Profile {
  isDefault: boolean;
  directoryBasename?: string;
}

export enum SidebarNodeType {
  Tab = "tab",
  ArcDocument = "arcDocument",
  Easel = "easel",
  List = "list",
  ItemContainer = "itemContainer",
  SplitView = "splitView",
}

export interface SidebarNode {
  id: string;
  type: SidebarNodeType;
  title?: string;
  url?: string;
  documentId?: string;
  easelId?: string;
  children?: SidebarNode[];
}

export interface Space {
  id: string;
  title: string;
  profile: Profile;
  topApps: SidebarNode[];
  unpinned: SidebarNode[];
  pinned: SidebarNode[];
}
