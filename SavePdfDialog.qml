import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1

Item {
    id: savePdfDialog
    signal fileSelected(string filePath)
    property string defaultFileName: "rapport_hospitalisation.pdf"

    FileDialog {
        id: fileDialog
        title: qsTr("Choisir l’emplacement du fichier PDF")
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        nameFilters: ["Fichier PDF (*.pdf)"]
        fileMode: FileDialog.SaveFile
        defaultSuffix: "pdf"
        onAccepted: {
            var path = file
            console.log("#### --- : ", path)
            //if (!path.endsWith(".pdf"))
            //    path += ".pdf"
            defaultFileName = path
            savePdfDialog.fileSelected(path)
        }
        onRejected: console.log("❌ Sauvegarde annulée")
    }

    function open() {
        fileDialog.open()
    }
}