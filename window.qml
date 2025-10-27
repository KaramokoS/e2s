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
                    color: "red"
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
                            source: "https://lh3.googleusercontent.com/aida-public/AB6AXuB5jpKyTOFH9WTCPVlYzEc1TW5A7EorQBwVdxm8I9VVQ7wYC1puqKTykR5MPVQimhN_zDC29Ee8jJPfzD7n7az2HleobNiNDK_6J48D9SA-W22y6KMReLsEZFCpKfyw77sBKavJvvTYqxnYa1vkZO26_NewZOMNQ4NYixlpCRXgE0ReQfk-LdT70DqscdP9LUwGiEfZboeNJOdezivL_4gaBcFTgLot1eATQ4BBgKFcujRI6ggTGoEmj0WnhbuWEYdqYbG6FqBIr4FC"
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
                                text: "Dr. Emily Carter"
                                font.bold: true
                                font.pixelSize: 16
                                color: "#222"
                            }

                            Text {
                                text: "emily@doctor.com"
                                font.pixelSize: 16
                                color: "#555"
                            }
                        }
                    }
                }
                Rectangle {
                    color: "green"
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width
                    Layout.topMargin: 10
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 20

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
    }
}
