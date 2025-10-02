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