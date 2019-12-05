import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0 as QQC2

import org.kde.kirigami 2.3 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

import "utils.js" as Utils

Kirigami.FormLayout {
    id:root

    anchors.right: parent.right
    anchors.left: parent.left


    readonly property bool vertical: plasmoid.formFactor == PlasmaCore.Types.Vertical || (plasmoid.formFactor == PlasmaCore.Types.Planar && plasmoid.height > plasmoid.width)

    property alias cfg_fps: fps.value
    property alias cfg_showFps: showFps.checked
    property alias cfg_hideTooltip: hideTooltip.checked

    property string cfg_visualEffect
    property alias cfg_randomVisualEffect: randomShader.checked

    property alias cfg_preferredWidth: preferredWidth.value
    property alias cfg_autoExtend: autoExtend.checked
    property alias cfg_autoHide: autoHideBtn.checked
    property alias cfg_animateAutoHiding: animateAutoHiding.checked

    property alias cfg_gravity:gravity.currentIndex

    property string str_options: ''

    RowLayout {
        Kirigami.FormData.label: "Effect:"
        Layout.fillWidth: true

        QQC2.ComboBox {
            id:shader
            model: ListModel {
                id: shaderOptions
            }
            onCurrentIndexChanged:cfg_visualEffect= shaderOptions.get(currentIndex).text
            enabled:!randomShader.checked
        }
    }

    QQC2.CheckBox {
        id: randomShader
        text: i18nc("@option:check", "Random effect (on startup)")
    }
    QQC2.Label {
        visible:randomShader.checked
        text:"Unwanted effects can be removed <br/>from <a href='file:///"+Utils.get_root()+"/shaders/' >here</a>."
        onLinkActivated: Qt.openUrlExternally(link)
    }

    QQC2.SpinBox {
        id:fps
        Kirigami.FormData.label:i18nc("@label:spinbox","FPS:")
        editable:true
        stepSize:1
        from:1
        to:300
    }

    QQC2.Label {
        text: "Lower FPS saves CPU and battries."
    }

    QQC2.CheckBox {
        id:showFps
        text: i18nc("@option:radio", "Show FPS")
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    QQC2.CheckBox {
        id:autoHideBtn
        text: i18nc("@option:radio", "Auto-hide (when audio is gone)")
        onCheckedChanged:{
            autoExtend.checked=autoHideBtn.checked?false:autoExtend.checked
        }
    }

    QQC2.CheckBox {
        id:animateAutoHiding
        visible:autoHideBtn.checked
        text: i18nc("@option:radio", "Animate auto-hiding")
    }

    QQC2.SpinBox {
        id: preferredWidth

        Kirigami.FormData.label: vertical ? i18nc("@label:spinbox", "Height:"):i18nc("@label:spinbox", "Width:")
        editable:true
        stepSize:10

        from: 1
        to:8000
    }

    QQC2.CheckBox {
        id: autoExtend
        enabled:!autoHideBtn.checked
        text: vertical?i18nc("@option:check", "Fill height (don't work with Auto-hiding)"):i18nc("@option:check", "Fill width (don't work with Auto-hiding)")
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    RowLayout {
        Kirigami.FormData.label: "Gravity:"
        Layout.fillWidth: true

        QQC2.ComboBox {
            id:gravity
            model:  ['Center','North','South','East','West']
        }
    }

    QQC2.CheckBox {
        id:hideTooltip
        text: i18nc("@option:check", "Hide tooltip")
    }

    QQC2.Label {
        id:cons
        text: str_options
    }

    readonly property string sh_get_devices:'sh '+'"'+Utils.get_scripts_root()+'/get-devices.sh'+'" '
    readonly property string sh_get_styles:'sh '+'"'+Utils.get_scripts_root()+'/get-shaders.sh'+'" '

    PlasmaCore.DataSource {
        //id: getOptionsDS
        engine: 'executable'
        connectedSources: [
            sh_get_styles
        ]
        onNewData: {
            if(sourceName==sh_get_devices){
            }else if(sourceName==sh_get_styles){
                var lst=data.stdout.substr(0,data.stdout.length-1).split('\n')
                for(var i in lst)
                    shaderOptions.append({text:lst[i]})
                for(var i=0;i<lst.length;i++)
                    if(shaderOptions.get(i).text==cfg_visualEffect)
                        shader.currentIndex=i;
            }
        }
    }
}
