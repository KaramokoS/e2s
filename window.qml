import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    width: 1200
    height: 800
    visible: true
    title: "Stitch Design - Dashboard"

    Row {
        anchors.fill: parent

        // --- Sidebar ---
        Rectangle {
            width: 240
            color: "#ffffff"
            border.color: "#dddddd"
            Column {
                anchors.fill: parent
                spacing: 20
                padding: 16

                Row {
                    spacing: 12
                    Image {
                        source: "https://lh3.googleusercontent.com/aida-public/AB6AXuB5jpKyTOFH9WTCPVlYzEc1TW5A7EorQBwVdxm8I9VVQ7wYC1puqKTykR5MPVQimhN_zDC29Ee8jJPfzD7n7az2HleobNiNDK_6J48D9SA-W22y6KMReLsEZFCpKfyw77sBKavJvvTYqxnYa1vkZO26_NewZOMNQ4NYixlpCRXgE0ReQfk-LdT70DqscdP9LUwGiEfZboeNJOdezivL_4gaBcFTgLot1eATQ4BBgKFcujRI6ggTGoEmj0WnhbuWEYdqYbG6FqBIr4FC"
                        width: 48; height: 48
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        text: "Dr. Emily Carter"
                        font.bold: true
                        font.pixelSize: 16
                        color: "#222"
                    }
                }

                Column {
                    spacing: 8
                    Repeater {
                        model: ["Dashboard", "Patients", "Appointments", "Prescriptions", "Settings"]
                        delegate: Button {
                            text: modelData
                            background: Rectangle {
                                color: hovered ? "#e6f4fb" : "transparent"
                            }
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }

        // --- Main Content ---
        Flickable {
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: column.implicitHeight

            Column {
                id: column
                width: parent.width
                spacing: 32
                padding: 24

                Text {
                    text: "Dashboard"
                    font.pixelSize: 28
                    font.bold: true
                }

                // --- Patient Overview ---
                Rectangle {
                    width: parent.width - 64
                    height: 160
                    color: "#ffffff"
                    border.color: "#dddddd"
                    Row {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 20
                        Column {
                            spacing: 6
                            Text { text: "Patient: Sarah Johnson"; font.bold: true; font.pixelSize: 16 }
                            Text { text: "Age: 45, Gender: Female"; color: "#666"; font.pixelSize: 13 }
                        }
                        Image {
                            source: "https://lh3.googleusercontent.com/aida-public/AB6AXuDKphM2AfRWzbV0tszprcvtPldzYd1a2oKYJVLxSBQmA-erGQom8Pk8tdBK79dHcyg5nmnKgPkT8wWYqzX9ESamVBSlXVJcK_obY-VY6rxabRezgfIpLiVwjco4YKothRIYTMwlumhvZXSy_mhp4oqGgI8f9YsC3D1plSm6xnNCTGPlIH0S485W6n5NIocBlSMdWrRPPpoWqiTX6XHMzvtpazkCvMWekQ46Nff4RcA5oNyHC2kZJRuOT5YUZWtth-ABoiBTmUBeYf7l"
                            width: 200; height: 120
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                }

                // --- Appointments Table ---
                Column {
                    spacing: 12
                    Text { text: "Upcoming Appointments"; font.pixelSize: 20; font.bold: true }

                    TableView {
                        anchors.fill: parent
                        columnSpacing: 1
                        rowSpacing: 1

                        model: ListModel {
                            ListElement { name: "Alice"; age: 24 }
                            ListElement { name: "Bob"; age: 30 }
                        }

                        delegate: Rectangle {
                            implicitHeight: 30
                            implicitWidth: 100
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: styleData.value
                            }
                        }
                    }
                }

                // --- Prescriptions Table ---
                Column {
                    spacing: 12
                    Text { text: "Quick Prescriptions"; font.pixelSize: 20; font.bold: true }

                    TableView {
                        anchors.fill: parent
                        columnSpacing: 1
                        rowSpacing: 1

                        model: ListModel {
                            ListElement { name: "Alice"; age: 24 }
                            ListElement { name: "Bob"; age: 30 }
                        }

                        delegate: Rectangle {
                            implicitHeight: 30
                            implicitWidth: 100
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: styleData.value
                            }
                        }
                    }
                }
            }
        }
    }
}
