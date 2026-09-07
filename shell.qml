import Quickshell
import Quickshell.Widgets
import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import "bar"

ShellRoot {

    GlobalShortcut {
        name: "launcher"
        onReleased: dynamicIsland.islandState = dynamicIsland.islandState === "launcher" ? "" : "launcher"
    }
    
    GlobalShortcut {
        name: "powermenu"
        onPressed: dynamicIsland.islandState = dynamicIsland.islandState === "powermenu" ? "" : "powermenu"
    }

    GlobalShortcut {
        name: "wallpaperswitcher"
        onPressed: dynamicIsland.islandState = dynamicIsland.islandState === "wallpaperswitcher" ? "" : "wallpaperswitcher"
    }

    GlobalShortcut {
        name: "homeassistant"
        onPressed: dynamicIsland.islandState = dynamicIsland.islandState === "homeassistant" ? "" : "homeassistant"
    }

    GlobalShortcut {
        name: "hovered"
        onPressed: dynamicIsland.islandState = dynamicIsland.islandState === "hovered" ? "" : "hovered"
    }

    GlobalShortcut {
        name: "normal"
        onPressed: dynamicIsland.islandState = ""
    }

    IpcHandler {
        target: "island"
        function show(name: string): void { dynamicIsland.islandState = name }
        function hide(): void { dynamicIsland.islandState = "" }
        function current(): string { return dynamicIsland.islandState }
    }

    Bar {}
    DynamicIsland {
        id: dynamicIsland



        //-------Konfiguration--------
        browser: "firefox"

        // Coordinates of your location, if you want to use the weather widget
        weatherLat: NaN
        weatherLon: NaN
        
        wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
        downloadDir: Quickshell.env("HOME") + "/Downloads"
        scriptDir: Quickshell.env("HOME") + "/scripts"
        //----------------------------
    }
}
