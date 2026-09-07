import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Variants {
    model: Quickshell.screens
    delegate: Component {
        PanelWindow {

            component Pill: Rectangle {
                id: pill
                default property alias content: inner.children
                property var clickCommand: null

                implicitHeight: 25
                border.color: "white"
                border.width: 1
                color: Qt.rgba(0,0,0,0.7)
                radius: 12.5

                Item {
                    id: inner
                    anchors.fill: parent

                    MouseArea {
                        anchors.fill: parent
                        enabled: pill.clickCommand !== null
                        hoverEnabled: enabled
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(pill.clickCommand)
                    }
                }
            }

            id: panelwindow
            required property var modelData
            screen: modelData
            color: "transparent"
            implicitHeight: 25
            exclusionMode: ExclusionMode.Ignore
            anchors {
                top: true
                left: true
                right: true
            }
            margins {
                top: 10
                right: 10
                left: 10
            }

            
            //Workspace
            Pill {
                anchors.top: parent.top
                implicitWidth: 50

                Text {
                    id: workspace
                    anchors.centerIn: parent
                    font.family: "Noto Sans"
                    color: "white"
                    text: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.activeWorkspace.name : ""
                }
            }


            //Temp
            Process {
                id: tempprocess
                running: true
                command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do case \"$(cat $h/name)\" in coretemp|k10temp) cat $h/temp1_input; break;; esac; done"]
                stdout: StdioCollector {
                    onStreamFinished: temptext.text = Math.round(parseInt(this.text) / 1000) + "°C"
                }
            }   

            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: tempprocess.running = true
            }

            Pill {
                id: temprect
                clickCommand: ["kitty", "--title", "btop", "btop"]
                implicitWidth: 50
                anchors.right: parent.right
                anchors.top: parent.top

                Text {
                    id: temptext
                    anchors.centerIn: parent
                    font.family: "Noto Sans"
                    color: "white"
                }
            }


            //RAM
            Process {
                id: memprocess
                running: true
                command: ["bash", "-c", "free -m | awk '/^Mem:/ {printf \"%d%%\", $3/$2*100}'"]
                stdout: StdioCollector {
                    onStreamFinished: memtext.text = "RAM: " + this.text
                }
            }

            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: memprocess.running = true
            }    
         
            Pill {
                id: ramrect
                anchors.rightMargin: 10
                anchors.right: temprect.left
                anchors.top: parent.top
                implicitWidth: 80
                clickCommand: ["kitty", "--title", "btop", "btop"]

                Text {
                    id: memtext
                    anchors.centerIn: parent
                    font.family: "Noto Sans"
                    color: "white"
                }    
            }


            //CPU-Usage
            Process {
                id: cpuprocess
                running: true
                command: ["bash", "-c", "top -bn1 | awk '/Cpu\\(s\\)/ {printf \"%d%%\", 100-$8}'"]
                stdout: StdioCollector {
                    onStreamFinished: cputext.text = "CPU: " + this.text
                }
            }

            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: cpuprocess.running = true
            }

            Pill {
                id: cpurect
                clickCommand: ["kitty", "--title", "btop", "btop"]
                anchors.rightMargin: 10
                anchors.right: ramrect.left
                anchors.top: parent.top
                implicitWidth: 75

                Text {
                    id: cputext
                    anchors.centerIn: parent
                    font.family: "Noto Sans"
                    color: "white"
                }
            }


            //Network
            Process {
                id: networkprocess
                running: true
                command: ["bash", "-c", "nmcli -t -f STATE general | grep -q '^connected' && echo 'Connected' || echo 'Disconnected'"]
                stdout: StdioCollector {
                    onStreamFinished: networktext.text = this.text
                }
            }

            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: networkprocess.running = true
            }

           Pill {
                id: networkrect
                clickCommand: ["kitty", "--title", "nmtui", "nmtui"]
                anchors.rightMargin: 10
                anchors.right: cpurect.left
                anchors.top: parent.top
                implicitWidth: 90

                Text {
                    id: networktext
                    anchors.centerIn: parent
                    font.family: "Noto Sans"
                    color: "white"
                }
            }
        }
    }
}
