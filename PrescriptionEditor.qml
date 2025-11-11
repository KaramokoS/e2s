import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    anchors.fill: parent

    signal saveRequested(string prescriptionJson)
    signal printRequested(string prescriptionJson)
    signal shareRequested(string prescriptionJson, string target)

    // ---- Nouveau modèle ----
    ListModel {
        id: medsModel
        ListElement { title: ""; dci: ""; details: ""; qty: 1 }
    }

    // ---- Données patient / médecin ----
    property string patientName: ""
    property string patientId: ""
    property date prescriptionDate: new Date()
    property string doctorName: ""
    property string doctorSpecialty: ""
    property string doctorCity: ""
    property string doctorPhone: ""
    property string doctorOrderNumber: ""
    property string clinicName: ""

    // ---- Génération du JSON au format cible ----
    function buildPrescriptionJson() {
        var prescs = [];
        for (var i = 0; i < medsModel.count; ++i) {
            var e = medsModel.get(i);
            if (!e.title || e.title.trim() === "") continue;
            prescs.push({
                title: e.title,
                dci: e.dci,
                details: e.details,
                qty: Number(e.qty) || 1
            });
        }

        var payload = {
            doctor: {
                name: root.doctorName,
                specialty: root.doctorSpecialty,
                city: root.doctorCity,
                phone: root.doctorPhone,
                order_number: root.doctorOrderNumber
            },
            patient: {
                name: root.patientName,
                ID: root.patientId
            },
            date: Qt.formatDate(root.prescriptionDate, "d/M/yyyy"),
            prescriptions: prescs
        };
        return JSON.stringify(payload, null, 2);
    }

    // ---- Interface graphique ----
    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Patient
        GroupBox {
            title: qsTr("Patient")
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 6
                RowLayout {
                    spacing: 8
                    TextField {
                        placeholderText: qsTr("Nom du patient")
                        text: root.patientName
                        onTextChanged: root.patientName = text
                        Layout.fillWidth: true
                    }
                    TextField {
                        id: patientIdField
                        placeholderText: qsTr("ID patient")
                        text: root.patientId
                        onTextChanged: root.patientId = text
                        width: 160
                    }
                }
            }
        }

        // Médecin
        GroupBox {
            title: qsTr("Médecin")
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 6
                RowLayout {
                    spacing: 8
                    TextField {
                        placeholderText: qsTr("Nom")
                        text: root.doctorName
                        onTextChanged: root.doctorName = text
                        Layout.fillWidth: true
                    }
                    TextField {
                        placeholderText: qsTr("Spécialité")
                        text: root.doctorSpecialty
                        onTextChanged: root.doctorSpecialty = text
                        Layout.preferredWidth: 160
                    }
                }
                RowLayout {
                    spacing: 8
                    TextField {
                        placeholderText: qsTr("Ville")
                        text: root.doctorCity
                        onTextChanged: root.doctorCity = text
                        Layout.fillWidth: true
                    }
                    TextField {
                        placeholderText: qsTr("Téléphone")
                        text: root.doctorPhone
                        onTextChanged: root.doctorPhone = text
                        Layout.preferredWidth: 160
                    }
                    TextField {
                        placeholderText: qsTr("N° d’ordre")
                        text: root.doctorOrderNumber
                        onTextChanged: root.doctorOrderNumber = text
                        Layout.preferredWidth: 160
                    }
                }
            }
        }

        // Date
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Label { text: qsTr("Date de prescription :") }
            TextField {
                text: Qt.formatDate(root.prescriptionDate, "dd/MM/yyyy")
                onEditingFinished: {
                    var parts = text.split("/");
                    if (parts.length === 3) {
                        var d = new Date(parts[2], parts[1]-1, parts[0]);
                        if (!isNaN(d)) root.prescriptionDate = d;
                    }
                }
                width: 140
            }
        }

        Rectangle { height: 1; color: "lightgray"; Layout.fillWidth: true; opacity: 0.5 }

        // ---- Liste des prescriptions ----
        Label { text: qsTr("Prescriptions"); font.bold: true }

        ListView {
            id: medsListView
            Layout.fillWidth: true
            Layout.preferredHeight: 350
            model: medsModel
            clip: true

            delegate: Item {
                width: parent.width
                height: content.implicitHeight + 10

                Rectangle { anchors.fill: parent; color: index % 2 === 0 ? "transparent" : "#f8f8f8" }

                ColumnLayout {
                    id: content
                    anchors.margins: 6
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 6

                    TextField {
                        placeholderText: qsTr("Titre du médicament")
                        text: title
                        onTextChanged: medsModel.set(index, { title: text, dci: dci, details: details, qty: qty })
                        Layout.fillWidth: true
                    }

                    TextField {
                        placeholderText: qsTr("DCI (substance active)")
                        text: dci
                        onTextChanged: medsModel.set(index, { title: title, dci: text, details: details, qty: qty })
                        Layout.fillWidth: true
                    }

                    TextArea {
                        placeholderText: qsTr("Détails (Posologie/fréquence, ex: 1 comprimé 2x/j, durée, etc.)")
                        text: details
                        wrapMode: Text.Wrap
                        onTextChanged: medsModel.set(index, { title: title, dci: dci, details: text, qty: qty })
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: 8
                        SpinBox {
                            from: 1; to: 20
                            value: qty
                            onValueChanged: medsModel.set(index, { title: title, dci: dci, details: details, qty: value })
                            ToolTip.text: qsTr("Quantité")
                            Layout.preferredWidth: 100
                        }

                        Button {
                            text: qsTr("Supprimer")
                            onClicked: medsModel.remove(index)
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: qsTr("Ajouter un médicament")
                onClicked: medsModel.append({ title: "", dci: "", details: "", qty: 1 })
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Sauvegarder PDF")
                onClicked: {
                    var json = buildPrescriptionJson()
                    root.saveRequested(json)
                    saveDialog.open()
                }
            }

            Button {
                text: qsTr("Imprimer")
                onClicked: root.printRequested(buildPrescriptionJson())
            }
        }
    }

    Component.onCompleted: {
        if (medsModel.count === 0)
            medsModel.append({ title: "", dci: "", details: "", qty: 1 })
    }

    SavePdfDialog {
        id: saveDialog
        onFileSelected: function(path) {
            console.log("PDF sera sauvegardé dans :", path)
            var json = buildPrescriptionJson()
            PrescriptionBackend.generatePrescriptionPDF(json, path)
        }
    }

    function loadFromJson(prescriptionJson) {
        try {
            var obj = JSON.parse(prescriptionJson)
            root.doctorName = obj.doctor.name || ""
            root.doctorSpecialty = obj.doctor.specialty || ""
            root.doctorCity = obj.doctor.city || ""
            root.doctorPhone = obj.doctor.phone || ""
            root.doctorOrderNumber = obj.doctor.order_number || ""
            root.patientName = obj.patient.name || ""
            root.patientId = obj.patient.patientId || ""
            root.prescriptionDate = obj.date ? new Date(obj.date) : new Date()

            medsModel.clear()
            if (obj.prescriptions && obj.prescriptions.length > 0) {
                for (var i = 0; i < obj.prescriptions.length; ++i) {
                    var m = obj.prescriptions[i]
                    medsModel.append({
                        title: m.title || "",
                        dci: m.dci || "",
                        details: m.details || "",
                        qty: m.qty || 1
                    })
                }
            }
        } catch (e) {
            console.warn("Erreur de chargement JSON", e)
        }
    }

    // Notes d'intégration :
    // - Connectez les signaux saveRequested/printRequested/shareRequested depuis C++ ou JS pour effectuer
    //   la persistance (BD, dossier partagé), génération PDF, ou envoi sécurisé.
    // - Implémentez côté backend toutes les règles de sécurité et audit (horodatage, utilisateur auteur).
    // - Respectez la réglementation locale (signature numérique, traçabilité, confidentialité).
}
