import QtQuick
import Quickshell.Io
import qs.Ui

// Indicador de grabacion de resumeet. Un clic alterna grabar/parar (meet-rec).
//
// El estado sale del mtime del state file que escribe meet-rec, no de un
// contador propio: asi el widget sigue mostrando los minutos correctos aunque
// el shell se reinicie a mitad de una reunion, y tambien si la grabacion se
// arranco por el atajo de teclado en vez del clic.
BarWidget {
  id: root
  moduleName: "io.github.cristosolar.resumeet"

  property int startedAt: 0
  property double now: 0

  readonly property bool recording: startedAt > 0
  readonly property int minutes: recording ? Math.max(0, Math.floor((now - startedAt) / 60)) : 0
  readonly property string icon: "󰑊"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() {
    root.now = Date.now() / 1000
    if (!statusProc.running) statusProc.running = true
  }

  Process {
    id: statusProc
    command: ["bash", "-c", "stat -c %Y \"${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/meet-rec.state\" 2>/dev/null || echo 0"]
    stdout: StdioCollector {
      onStreamFinished: root.startedAt = parseInt(text.trim(), 10) || 0
    }
  }

  // 5 s basta: lo que se muestra son minutos.
  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.recording && !root.vertical ? root.icon + "  " + root.minutes + "m" : root.icon
    active: root.recording
    dimmed: !root.recording
    tooltipText: root.recording
      ? "Grabando hace " + root.minutes + " min — clic para parar y transcribir"
      : "Grabar reunion"
    onPressed: function(b) {
      if (root.bar) root.bar.run("meet-rec")
      // Rebote optimista: el state file aparece o desaparece enseguida, pero
      // meet-rec tarda ~1 s en confirmar que ffmpeg arranco.
      confirmTimer.restart()
    }
  }

  Timer {
    id: confirmTimer
    interval: 1500
    onTriggered: root.refresh()
  }
}
