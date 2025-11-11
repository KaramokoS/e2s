import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


ApplicationWindow {
    width: 1200
    height: 800
    visible: true
    title: "Stitch Design - Dashboard"
    property var colors: Qt.createComponent("Colors.qml").createObject(this)
    //property var prescription: Qt.createComponent("PrescriptionEditor.qml").createObject(this)

    background: Rectangle {
        color: Colors.backgroundColor
    }

    RowLayout {
        anchors.fill: parent
        spacing: 30
        Rectangle {
            id : _menu
            color: "white"
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.3
            Layout.topMargin: 50
            radius: 8    // optional rounded corners
            border.color: "#ddd"

            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                anchors.margins: 20  // internal padding
                Rectangle {
                    id : _doctor
                    color: "white"
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 0.1*parent.height
                    Layout.topMargin: 10
                    RowLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        Layout.alignment: Qt.AlignTop
                        spacing: 12
                        Image {
                            source: "static/doctor.jpeg"
                            fillMode: Image.PreserveAspectFit
                            Layout.preferredWidth: 0.4*parent.width
                            Layout.preferredHeight: parent.height
                            Layout.alignment: Qt.AlignTop
                        }
                        ColumnLayout {
                            spacing: 10
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop

                            Text {
                                text: "Dr. Cheick Oumar Coulibaly"
                                font.bold: true
                                font.pixelSize: 16
                                color: "#222"
                            }

                            Text {
                                text: "cheick@doctor.com"
                                font.pixelSize: 16
                                color: "#555"
                            }
                        }
                    }
                }
                Rectangle {
                    color: "white"
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width
                    Layout.topMargin: 10
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 20

                        Button {
                            text: "Calendrier"
                            font.bold: true
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                color: "#ffffff"
                                radius: 8
                                border.color: "#dddddd"
                            }
                            onClicked: {
                                if (stack.depth > 1) {
                                    // Return all the way to the dashboard (first screen)
                                    while (stack.depth > 1)
                                        stack.pop()
                                }
                            }
                        }

                        Button {
                            text: "Patients"
                            font.bold: true
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                color: "#ffffff"
                                radius: 8
                                border.color: "#dddddd"
                            }
                            onClicked: stack.push("patientMenu.qml")
                        }

                        Button {
                            text: "Hospitalisation"
                            font.bold: true
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                color: "#ffffff"
                                radius: 8
                                border.color: "#dddddd"
                            }
                            onClicked: stack.push("Hospitalization.qml")
                        }
                    }
                }
            }
        }

        Rectangle {
            id: _content
            color: "white"
            Layout.fillHeight: true
            Layout.preferredWidth: 0.7 * parent.width
            Layout.topMargin: 50

            // --- Main Content ---
            StackView {
                id: stack
                anchors.fill: parent
                initialItem:  Flickable {
                //id : DashboardPage
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
                                Text { text: "Patient: Moussa Kansaye"; font.bold: true; font.pixelSize: 16 }
                                Text { text: "Age: 45, Sexe: Masculin"; color: "#666"; font.pixelSize: 13 }
                            }
                            Image {
                                source: "static/patient.jpg"
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
    }
}
