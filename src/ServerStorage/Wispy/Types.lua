----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Core |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
export type Config = {
    Name: string,
    Version: string,
    AssetID: number?
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Systems |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
export type System = {
    Preload: (self: System) -> nil,
    Mount: (self: System) -> nil,
    OnClose: (self: System) -> nil,

    GetSystem: <SystemName>(self: System, SystemName: string) -> any,
    GetLib: <LibraryName>(self: System, LibraryName: string) -> any,

    Plugin: Plugin,
    Maid: MaidObject,
    NoMount: boolean,
    LocalPlayer: Player,
    Config: Config
}

export type AvatarSystem = {
    createAvatar: <playerName>(self: AvatarSystem, playerName: string) -> nil
} & System

export type ChatSystem = {
    ClearLogs: (self: ChatSystem) -> nil,
    UpdateChat: (self: ChatSystem) -> nil,
    UpdatePlrList: (self: ChatSystem) -> nil
} & System

export type FileSystem = {
    Get: <Name>(self: PluginUI, Name: string) -> Folder,
} & System

export type PluginUI = {
    GetWidget: <Name>(self: PluginUI, Name: string) -> DockWidgetPluginGui,
    GetButton: <Name>(self: PluginUI, Name: string) -> PluginToolbarButton
} & System

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Utilities |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
export type MaidObject = {
    Add: <Event>(self: MaidObject, Event: RBXScriptConnection) -> nil,
    Clean: (self: MaidObject) -> nil
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--| Library |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
export type RichTextObject = {
    Animate: <yield>(self: RichTextObject, yeild: number) -> nil,
    Show: <finishAnimation>(self: RichTextObject, finishAnimation: any) -> nil,
    Hide: (self: RichTextObject) -> nil
}

export type RichText = {
    New: <frame, text, startingProperties, allowOverflow, prevTextObject>(self: RichText, frame: Frame, startingProperties: any, allowOverflow: boolean, prevTextObject: any) -> RichTextObject
}

export type DeferObject = {
    Call: (self: DeferObject) -> nil,
    Clean: (self: DeferObject) -> nil
}

export type Defer = {
    new: <Callback, Timeout>(Callback: (any) -> any, Timeout: number) -> DeferObject    
}

return {}