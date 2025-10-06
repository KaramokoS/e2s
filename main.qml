import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Hello QML + Python"

    Rectangle {
        anchors.fill: parent
        color: "lightblue"

        Text {
            anchors.centerIn: parent
            text: "Hello from QML!"
            font.pixelSize: 24
        }
    }
}




                    TableView {
                        width: parent.width - 64
                        height: 200
                        clip: true

                        TableViewColumn { role: "date"; title: "Date"; width: 150 }
                        TableViewColumn { role: "time"; title: "Time"; width: 100 }
                        TableViewColumn { role: "patient"; title: "Patient"; width: 200 }
                        TableViewColumn { role: "reason"; title: "Reason"; width: 200 }

                        model: ListModel {
                            ListElement { date: "2024-03-15"; time: "10:00 AM"; patient: "Sarah Johnson"; reason: "Routine Checkup" }
                            ListElement { date: "2024-03-16"; time: "2:00 PM"; patient: "Mark Thompson"; reason: "Follow-up" }
                            ListElement { date: "2024-03-17"; time: "11:00 AM"; patient: "Olivia Davis"; reason: "Consultation" }
                        }
                    }


                    TableView {
                        width: parent.width - 64
                        height: 200

                        TableViewColumn { role: "med"; title: "Medication"; width: 200 }
                        TableViewColumn { role: "dose"; title: "Dosage"; width: 100 }
                        TableViewColumn { role: "freq"; title: "Frequency"; width: 150 }
                        TableViewColumn { role: "patient"; title: "Patient"; width: 200 }

                        model: ListModel {
                            ListElement { med: "Medication A"; dose: "500mg"; freq: "Twice daily"; patient: "Sarah Johnson" }
                            ListElement { med: "Medication B"; dose: "250mg"; freq: "Once daily"; patient: "Mark Thompson" }
                        }
                    }



    Row {
        anchors.fill: parent
        spacing: 2

        // --- Sidebar ---
        Rectangle {
            width: 240
            color: "green"
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
