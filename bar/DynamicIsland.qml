import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Qt.labs.folderlistmodel
import Quickshell.Services.Notifications
import Quickshell.Widgets

Scope {


    // ----------- Konfiguration ----------------
    property string browser: "firefox"
    property real weatherLat: NaN
    property real weatherLon: NaN
    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property string downloadDir: Quickshell.env("HOME") + "/Downloads"
    property string scriptDir: Quickshell.env("HOME") + "/scripts"
    // ------------------------------------------





    property string islandState: ""
    readonly property bool weatherConfigured: !isNaN(weatherLat) && !isNaN(weatherLon)
    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: placeholder
                required property var modelData
                screen: modelData
                implicitHeight: 35
                anchors.top: true
                anchors.right: true
                anchors.left: true
                color: "transparent"
                mask: Region{}
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {

                mask: Region { item: island }

                WlrLayershell.keyboardFocus: islandState !== "" && islandState !== "notifications" && Quickshell.screens[0] === modelData ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

                WlrLayershell.layer: islandState !== "" && Quickshell.screens[0] == modelData ? WlrLayer.Overlay : WlrLayer.Top

                WlrLayershell.exclusiveZone: -1
                id: panelwindow
                required property var modelData
                screen: modelData
                color: "transparent"
                property bool hovered: pillHover.hovered
                property int selectedPowerState: 1
                property string selectedWallpaper

                property var currentNotif: null

                property real weatherTemp: 0
                property real weatherRain: 0
                property real weatherWind: 0
                property int weatherCloud: 0

                implicitWidth: 800
                implicitHeight: 600

                anchors { top: true }
                margins { top: 10 }

                SystemClock {
                    id: clock
                    precision: SystemClock.Seconds
                }

                Rectangle {
                    id: island
                    anchors.top: parent.top
                    width: 80
                    height: 25
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Qt.rgba(0,0,0,0.7)
                    border.color: "white"
                    border.width: 1
                    radius: 12.5
                    HoverHandler { id: pillHover }
                    property int powerMenuFontSize: 0
                    state: Quickshell.screens[0] === modelData ? islandState : ""
                    onStateChanged: { if (state !== "") textinput.clear() }

                    function launchSelected() {
                        var entry = applicationlistview.model[applicationlistview.currentIndex]
                        if (entry) {
                            entry.execute()
                            islandState = ""
                        }
                    }

                    Process {
                        id: googleSelected
                        property string query: textinput.text.substring(2)
                        command: [browser, query.includes(".") && !query.includes(" ")
                            ? query
                            : "https://www.google.com/search?q=" + encodeURIComponent(query)]
                    }

                    Process {
                        id: youtubeSelected
                        property string query: textinput.text.substring(3)
                        command: [browser, query.includes(".") && !query.includes(" ")
                            ? query
                            : "https://www.youtube.com/results?search_query=" + encodeURIComponent(query)]
                    }

                    Process {
                        id: amazonSelected
                        property string query: textinput.text.substring(2)
                        command: [browser, query.includes(".") && !query.includes(" ")
                            ? query
                            : "https://www.amazon.de/s?k=" + encodeURIComponent(query)]
                    }

                    Process {
                        id: fpvSelected
                        property string query: encodeURIComponent(textinput.text.substring(4))
                        command: [browser, "https://www.hobbydrone.cz/de/suche/?string=" + query, "https://www.rotorama.de/hledani?q=" + query, "https://www.fpv24.com/de/search?search=" + query, "https://iflight-rc.eu/en/search?q=" + query, "https://n-factory.de/#bms_q=" + query, "https://www.drone-fpv-racer.com/en/?gad_source=1&gad_campaignid=20588861672#557a/embedded/m=f&q=" + query, "https://www.amazon.de/s?k=" + query, "https://de.aliexpress.com/w/wholesale-" + query + ".html?spm=a2g0o.home.search.0", "https://www.google.com/search?q=" + query]
                    }

                    Process {
                        id: audioSelected
                        property string query: textinput.text.substring(4).trim()
                        command: ["kitty", "-e", "yt-dlp", "--cookies-from-browser", browser, "-t", "mp3",
                                  "-P", downloadDir, query]
                    }

                    Process {
                        id: videoSelected
                        property string query: textinput.text.substring(4).trim()
                        command: ["kitty", "-e", "yt-dlp", "--cookies-from-browser", browser, "-t", "mp4",
                                  "-P", downloadDir, query]
                    }

                    Process {
                        id: runScript
                        property string query: textinput.text.substring(2)
                        command: ["sh", "-c", scriptDir + "/" + query]
                    }

                    Process {
                        id: runPackageSearch
                        property string query: textinput.text.substring(2)
                        command: ["kitty", "--hold", scriptDir + "/yays", query]
                    }
                    Process {
                        id: runInstall
                        property string query: textinput.text.substring(3)
                        command: ["kitty", "yay", "-S", "--noconfirm", query]
                    }

                Text {
                        id: timetext
                        text: Qt.formatTime(clock.date, "hh:mm")
                        anchors.centerIn: parent
                        font.family: "Noto Sans"
                        color: "white"
                    }

                    Text {
                        id: datetext
                        text: Qt.formatDate(clock.date, "dddd, dd.MM.yyyy")
                        font.family: "Noto Sans"
                        color: "white"
                        font.pixelSize: 26
                        scale: 0.2
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 0
                        opacity: 0
                    }

                    Rectangle {
                        id: inputrect
                        clip: true
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 12
                        width: 0
                        height: 0
                        color: Qt.rgba(0,0,0,0.3)
                        border.color: "white"
                        border.width: 1
                        radius: 12.5
                        opacity: 0

                        TextInput {
                            id: textinput
                            anchors.verticalCenter: parent.verticalCenter
                            width: 600
                            height: 20
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            font.pixelSize: 20
                            color: "white"
                            focus: false

                            Keys.onReturnPressed: if (islandState === "wallpaperswitcher") {
                                if (wallpaperlistview.currentItem) {
                                    selectedWallpaper = wallpaperlistview.currentItem.filePath
                                    wallpaperProcess.running = true
                                }
                                islandState = ""
                            } else {
                                if (textinput.text.startsWith("g ")) {
                                    googleSelected.running = true
                                    islandState = ""
                                } else if (textinput.text.startsWith("yt ")) {
                                    youtubeSelected.running = true
                                    islandState = ""
                                } else if (textinput.text.startsWith("a ")) {
                                    amazonSelected.running = true
                                    islandState = ""
                                } else if (textinput.text.startsWith("fpv ")) {
                                    fpvSelected.running = true
                                    islandState = ""
                                } else if (textinput.text.startsWith("mp3 ")) {
                                    audioSelected.running = true
                                    islandState = ""
                                } else if (textinput.text.startsWith("mp4 ")) {
                                    videoSelected.running = true
                                    islandState = ""
                                } else if (textinput.text.startsWith("s ")) {
                                    runScript.running = true
                                    islandState = ""
                                } else if (textinput.text.startsWith("i ")) {
                                    runPackageSearch.running = true
                                    islandState = ""
                                } else if (textinput.text.startsWith("ii ")) {
                                    runInstall.running = true
                                    islandState = ""
                                } else {
                                    island.launchSelected()
                                }
                            }

                            Keys.onEscapePressed: islandState = ""
                        }
                    }

                    ListView {
                        id: applicationlistview
                        property string applicationquery: textinput.text.toLowerCase()
                        model: DesktopEntries.applications.values.filter(function(entry) {
                            return applicationquery === "" || entry.name.toLowerCase().startsWith(applicationquery)
                        })
                        property real launcherScale: 0
                        property int rectWidth: 0
                        property int rectHeight: 0
                        spacing: 10
                        anchors.top: inputrect.bottom
                        anchors.topMargin: 0
                        anchors.horizontalCenter: inputrect.horizontalCenter
                        opacity: 0

                        delegate: Rectangle {
                            id: resultrect
                            required property var modelData
                            required property int index
                            width: applicationlistview.rectWidth
                            height: applicationlistview.rectHeight
                            color: Qt.rgba(0,0,0,0.3)
                            border.color: "white"
                            border.width: 1
                            radius: 12.5

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    applicationlistview.currentIndex = index
                                    island.launchSelected()
                                }
                            }

                            Text {
                                text: modelData.name
                                color: "white"
                                font.pixelSize: 24
                                scale: applicationlistview.launcherScale
                                anchors.centerIn: parent
                            }
                        }
                    }

                    Rectangle {
                        id: shutdownrect
                        anchors.centerIn: parent
                        width: 120
                        height: 120
                        scale: 0
                        color: selectedPowerState === 1 ? Qt.rgba(255,255,255,0.3) : Qt.rgba(0,0,0,0.3)
                        border.color: "white"
                        border.width: 1
                        radius: 12.5
                        opacity:0
                        
                        Text {
                            anchors.centerIn: parent
                            text: "⏻"
                            color: "white"
                            font.pixelSize: 40
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Rectangle {
                        id: rebootrect
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: 25
                        width: 120
                        height: 120
                        scale: 0
                        color: selectedPowerState === 2 ? Qt.rgba(255,255,255,0.3) : Qt.rgba(0,0,0,0.3)
                        border.color: "white"
                        border.width: 1
                        radius: 12.5
                        opacity: 0

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: "white"
                            font.pixelSize: 40
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Rectangle {
                        id: lockrect
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -25
                        width: 120
                        height: 120
                        scale: 0
                        color: selectedPowerState === 0 ? Qt.rgba(255,255,255,0.3) : Qt.rgba(0,0,0,0.3)
                        border.color: "white"
                        border.width: 1
                        radius: 12.5
                        opacity: 0

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: "white"
                            font.pixelSize: 40
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    Item {
                        id: powermenufocus
                        focus: false
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_H && selectedPowerState > 0) selectedPowerState--
                            if (event.key === Qt.Key_L && selectedPowerState < 2) selectedPowerState++
                            if (event.key === Qt.Key_Return) {
                                if (selectedPowerState === 0) {
                                    lockProcess.running = true
                                    islandState = ""
                                }
                                if (selectedPowerState === 1) {
                                    shutdownProcess.running = true
                                    islandState = ""
                                }
                                if (selectedPowerState === 2) {
                                    rebootProcess.running = true
                                    islandState = ""
                                }
                            }
                        }
                        Keys.onEscapePressed: islandState = ""
                    }

                    Process {
                        id: shutdownProcess
                        command: ["systemctl", "poweroff"]
                    }

                    Process {
                        id: rebootProcess
                        command: ["systemctl", "reboot"]
                    }

                    Process {
                        id: lockProcess
                        command: ["hyprlock"]
                    }

                    FolderListModel {
                        id: wallpaperFolderListModel
                        folder: "file://" + wallpaperDir
                        property string wallpaperquery: textinput.text
                        nameFilters: wallpaperquery !== "" ? [wallpaperquery + "*"] : ["*"]
                        caseSensitive: false
                        showDirs: false
                    }

                    Process {
                        id: wallpaperProcess
                        command: ["awww", "img", selectedWallpaper, "--transition-type", "grow", "--transition-pos", "0.5,0.5", "--transition-step", "5"]
                    }

                    ListView {
                        id: wallpaperlistview
                        orientation: ListView.Horizontal
                        property string wallpaperquery: textinput.text.toLowerCase()
                        model: wallpaperFolderListModel
                        property int rectWidth: 0
                        property int rectHeight: 0
                        spacing: 0
                        anchors.top: inputrect.bottom
                        anchors.topMargin: 0
                        anchors.horizontalCenter: inputrect.horizontalCenter
                        anchors.horizontalCenterOffset: 0
                        opacity: 0

                        delegate: ClippingRectangle {
                            id: wallpaperresultrect
                            required property string filePath
                            required property int index
                            width: wallpaperlistview.rectWidth
                            height: wallpaperlistview.rectHeight
                            color: Qt.rgba(0,0,0,0.7)
                            border.color: "white"
                            border.width: 1
                            radius: 12.5

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    selectedWallpaper = filePath
                                    wallpaperProcess.running = true
                                    islandState = ""
                                }
                            }

                            Image {
                                id: wallpaperimage
                                source: "file://" + filePath
                                sourceSize.width: 300
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                anchors.margins: 0
                                asynchronous: true
                            }
                        }
                    }

                    Process {
                        id: weatherProcess
                        command: ["curl", "-s", "https://api.open-meteo.com/v1/forecast?latitude=" + weatherLat + "&longitude=" + weatherLon + "&current=temperature_2m,rain,cloud_cover,wind_speed_10m&models=dwd_icon_seamless&forecast_days=1"]
                        stdout: StdioCollector {
                            onStreamFinished: {
                                var data = JSON.parse(text)
                                weatherTemp = data.current.temperature_2m
                                weatherRain = data.current.rain
                                weatherWind = data.current.wind_speed_10m
                                weatherCloud = data.current.cloud_cover
                            }
                        }
                    }

                    Timer {
                        interval: 60000
                        running: weatherConfigured
                        repeat: true
                        onTriggered: weatherProcess.running = true
                        triggeredOnStart: true
                    }

                    Rectangle {
                        id: weathertemprect
                        width: 0
                        height: 0
                        radius: 12.5
                        color: Qt.rgba(0,0,0,0)

                        Text {
                            id: weathertempicon
                            text: ""
                            color: "white"
                            font.pixelSize: 60
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 0
                            scale: 0.2
                            opacity: 0
                        }

                        Text {
                            id: weathertemptext
                            text: weatherConfigured ? panelwindow.weatherTemp + "°C" : "---"
                            color: "white"
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 0
                            anchors.verticalCenterOffset: 0
                            font.pixelSize: 20
                            scale: 0.2
                            opacity: 0
                        }
                    }

                    Rectangle {
                        id: weatherrainrect
                        width: 0
                        height: 0
                        radius: 12.5
                        color: Qt.rgba(0,0,0,0)

                        Text {
                            id: weatherrainicon
                            text: ""
                            color: "white"
                            font.pixelSize: 60
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 0
                            scale: 0.2
                            opacity: 0
                        }

                        Text {
                            id: weatherraintext
                            text: weatherConfigured ? panelwindow.weatherRain + "mm": "---"
                            color: "white"
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 0
                            anchors.verticalCenterOffset: 0
                            font.pixelSize: 20
                            scale: 0.2
                            opacity: 0
                        }
                    }

                    Rectangle {
                        id: weatherwindrect
                        width: 0
                        height: 0
                        radius: 12.5
                        color: Qt.rgba(0,0,0,0)

                        Text {
                            id: weatherwindicon
                            text: ""
                            color: "white"
                            font.pixelSize: 60
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 0
                            scale: 0.2
                            opacity: 0
                        }

                        Text {
                            id: weatherwindtext
                            text: weatherConfigured ? panelwindow.weatherWind + "km/h" : "---"
                            color: "white"
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 0
                            anchors.verticalCenterOffset: 0
                            font.pixelSize: 20
                            scale: 0.2
                            opacity: 0
                        }
                    }

                    Rectangle {
                        id: weathercloudrect
                        width: 0
                        height: 0
                        radius: 12.5
                        color: Qt.rgba(0,0,0,0)

                        Text {
                            id: weathercloudicon
                            text: ""
                            color: "white"
                            font.pixelSize: 60
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 0
                            scale: 0.2
                            opacity: 0
                        }

                        Text {
                            id: weathercloudtext
                            text: weatherConfigured ? panelwindow.weatherCloud + "%" : "---"
                            color: "white"
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 0
                            anchors.verticalCenterOffset: 0
                            font.pixelSize: 20
                            scale: 0.2
                            opacity: 0
                        }
                    }

                    NotificationServer {
                        id: notifServer
                        onNotification: (notification) => {
                            notification.tracked = true
                            currentNotif = notification
                            islandState = "notifications"
                            notifTimer.restart()
                        }
                    }

                    Text {
                        id: notifTitle
                        text: currentNotif ? currentNotif.summary : ""
                        color: "white"
                        font.family: "Noto Sans"
                        font.pixelSize: 26
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        width: 500
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        scale: 0.1
                        opacity: 0
                    }

                    Text {
                        id: notifBody
                        text: currentNotif ? currentNotif.body : ""
                        color: "white"
                        font.family: "Noto Sans"
                        font.pixelSize: 20
                        anchors.top: notifTitle.bottom
                        anchors.horizontalCenter: notifTitle.horizontalCenter
                        anchors.topMargin: -50
                        width: 500
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        scale: 0.1
                        opacity: 0
                    }

                    Timer {
                        id: notifTimer
                        interval: 5000
                        repeat: false
                        onTriggered: islandState = ""
                    }


                    states: [
                        State {
                            name: "hovered"
                            when: pillHover.hovered && islandState === "" && island.height <= 200
                            PropertyChanges {
                                target: island
                                width: 600
                                height: 200
                                radius: 30
                            }

                            PropertyChanges {
                                target: timetext
                                font.pixelSize: 26
                                anchors.verticalCenterOffset: -70
                                anchors.horizontalCenterOffset: 200
                            }

                            PropertyChanges {
                                target: datetext
                                opacity: 1
                                anchors.horizontalCenterOffset: -100
                                anchors.topMargin: 12
                                scale: 1
                            }

                            PropertyChanges {
                                target: weathertemprect
                                width: 600
                                height: 200
                            }

                            PropertyChanges {
                                target: weathertemptext
                                anchors.horizontalCenterOffset: -200
                                anchors.verticalCenterOffset: 60
                                scale: 1
                                opacity: 1
                            }

                            PropertyChanges {
                                target: weathertempicon
                                anchors.horizontalCenterOffset: -200
                                scale: 1
                                opacity: 1
                            }

                            PropertyChanges {
                                target: weatherrainrect
                                width: 600
                                height: 200
                            }

                            PropertyChanges {
                                target: weatherraintext
                                anchors.horizontalCenterOffset: -75
                                anchors.verticalCenterOffset: 60
                                scale: 1
                                opacity: 1
                            }

                            PropertyChanges {
                                target: weatherrainicon
                                anchors.horizontalCenterOffset: -75
                                anchors.verticalCenterOffset: -5
                                scale: 1
                                opacity: 1
                            }

                            PropertyChanges {
                                target: weatherwindrect
                                width: 600
                                height: 200
                            }

                            PropertyChanges {
                                target: weatherwindtext
                                anchors.horizontalCenterOffset: 75
                                anchors.verticalCenterOffset: 60
                                scale: 1
                                opacity: 1
                            }

                            PropertyChanges {
                                target: weatherwindicon
                                anchors.horizontalCenterOffset: 75
                                scale: 1
                                opacity: 1
                            }

                            PropertyChanges {
                                target: weathercloudrect
                                width: 600
                                height: 200
                            }

                            PropertyChanges {
                                target: weathercloudtext
                                anchors.horizontalCenterOffset: 200
                                anchors.verticalCenterOffset: 60
                                scale: 1
                                opacity: 1
                            }

                            PropertyChanges {
                                target: weathercloudicon
                                anchors.horizontalCenterOffset: 200
                                scale: 1
                                opacity: 1
                            }
                        },
                        State {
                            name: "launcher"
                            PropertyChanges {
                                target: island
                                width: 800
                                height: 600
                                radius: 30
                            }

                            PropertyChanges {
                                target: timetext
                                font.pixelSize: 28
                                anchors.verticalCenterOffset: -265
                            }

                            PropertyChanges {
                                target: inputrect
                                width: 700
                                height: 50
                                anchors.verticalCenterOffset: -200
                                opacity: 1
                            }

                            PropertyChanges {
                                target: applicationlistview
                                width: 600
                                height: 350
                                rectWidth: 700
                                rectHeight: 50
                                launcherScale: 1
                                anchors.topMargin: 80
                                anchors.horizontalCenterOffset: -50
                                opacity: 1
                            }

                            PropertyChanges {
                                target: textinput
                                focus: true
                            }
                        },
                        State {
                            name: "powermenu"
                            PropertyChanges {
                                target: island
                                width: 450
                                height: 150
                                radius: 25
                            }
                            
                            PropertyChanges {
                                target: timetext
                                anchors.verticalCenterOffset: -100
                            }

                            PropertyChanges {
                                target: shutdownrect
                                opacity: 1
                                scale: 1
                            }

                            PropertyChanges {
                                target: rebootrect
                                opacity: 1
                                anchors.horizontalCenterOffset: 150
                                scale: 1
                            }

                            PropertyChanges {
                                target: lockrect
                                opacity: 1
                                anchors.horizontalCenterOffset: -150
                                scale: 1
                            }

                            PropertyChanges {
                                target: powermenufocus
                                focus: true
                            }
                        },
                        State {
                            name: "wallpaperswitcher"
                            PropertyChanges {
                                target: island
                                width: 800
                                height: 510
                                radius: 30
                            }

                            PropertyChanges {
                                target: timetext
                                anchors.verticalCenterOffset: -220
                                font.pixelSize: 28
                            }

                            PropertyChanges {
                                target: inputrect
                                visible: true
                                anchors.verticalCenterOffset: -155
                                width: 700
                                height: 50
                                opacity: 1
                            }

                            PropertyChanges {
                                target: textinput
                                focus: true
                            }

                            PropertyChanges {
                                target: wallpaperlistview
                                width: 700
                                height: 300
                                rectWidth: 300
                                rectHeight: 300
                                anchors.topMargin: 35
                                spacing: 100
                                opacity: 1
                            }
                        },
                        State {
                            name: "notifications"
                            PropertyChanges {
                                target: island
                                width: 600
                                height: notifBody.text ? notifTitle.height + notifBody.height + 40 : notifTitle.height + 20
                            }

                            PropertyChanges {
                                target: notifTitle
                                scale: 1
                                opacity: 1
                            }

                            PropertyChanges {
                                target: notifBody
                                scale: 1
                                opacity: 1
                                anchors.topMargin: 10
                            }

                            PropertyChanges {
                                target: timetext
                                anchors.verticalCenterOffset: 0 - island.height / 2 - 20
                            }
                        }
                    ]

                    transitions: Transition {
                        NumberAnimation {
                            properties: "width, height, font.pixelSize, anchors.verticalCenterOffset, anchors.horizontalCenterOffset, anchors.topMargin, radius, rectWidth, rectHeight, opacity, spacing, scale, launcherScale"
                            duration: 500
                            easing.type: Easing.OutQuart
                        }
                    }
                }
            }
        }
    }
}
