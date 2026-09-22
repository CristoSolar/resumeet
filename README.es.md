# Resumeet

*[Read in English](README.md)*

Graba una reunión (Meet, Zoom, lo que suene en el sistema), la transcribe en
local con whisper.cpp y corre **agentes** — prompts en archivos `.md` — sobre la
transcripción: resumen, pasos a seguir, o lo que cada uno escriba.

Todo corre en tu máquina. Solo el paso de agentes llama a un LLM, y ese comando
lo eliges tú.

![Resumeet: el widget grabando y el visor de reuniones](preview.png)

## Cómo funciona

```
atajo / widget de barra ──> meet-rec (toggle)
   │ start: ffmpeg graba mic y audio del sistema en 2 pistas WAV 16 kHz
   │ stop:  whisper-cli x2 (con VAD) → meet-merge → transcripcion.md
   │        por cada ~/.config/resumeet/agents/<nombre>.md
   │          $RESUMEET_LLM "<prompt>" < transcripcion.md > <nombre>.md
   └─> notificación "Reunión lista"          resumeet ──> visor local
```

Dos pistas separadas dan separación de hablante (`Yo` / `Ellos`) sin
diarización. El VAD (Silero) es obligatorio: sin él Whisper alucina frases
sobre los silencios, que son la mayoría de cada pista.

Salida en `~/Reuniones/2026-09-15_1130/`: `mic.wav`, `remoto.wav`,
`transcripcion.md`, y un `.md` por agente.

## Las tres piezas

### 1. Widget de barra (Omarchy)

Un indicador en la barra que muestra los minutos que llevas grabando y alterna
grabar/parar con un clic. Útil cuando la reunión se alarga y se te olvida que
estabas grabando.

![Widget con 25 minutos grabados](docs/bar-widget.png)

El widget lee el estado del archivo que escribe `meet-rec`, así que refleja
también las grabaciones iniciadas por el atajo de teclado, y sobrevive a un
reinicio del shell sin perder la cuenta.

### 2. El grabador

Un comando, `meet-rec`, alterna grabar/parar. `zenity` (opcional) pide el
título al empezar. Al parar transcribe ambas pistas, las mezcla en una sola
transcripción cronológica, corre todos los agentes y avisa.

```
meet-rec              alterna grabar/parar
meet-rec --status     estado actual
meet-rec --self-test  graba 4 s y corre el pipeline entero
```

### 3. El visor

`resumeet` abre un visor local (un servidor HTTP solo con stdlib en
`127.0.0.1:8765`) con el listado de reuniones: resumen, pasos a seguir,
transcripción completa y un reproductor por pista.

![Listado de reuniones](docs/app-meetings.png)

![Una reunión: pistas de audio, resumen y pasos a seguir](docs/app-meeting.png)

![La transcripción completa, con separación de hablante](docs/app-transcript.png)

La interfaz está en español e inglés — ver `RESUMEET_UI_LANG` más abajo.

## Agentes personalizados

Un agente es un archivo `~/.config/resumeet/agents/<nombre>.md` cuyo contenido
es el prompt. Cada usuario del sistema tiene su propio directorio, así que cada
uno arma sus agentes sin tocar los de los demás. El resultado queda en
`<nombre>.md` dentro de la carpeta de la reunión.

Ejemplo, `~/.config/resumeet/agents/mail.md`:

```
Redacta en español un correo de seguimiento breve para los participantes,
con los acuerdos y los próximos pasos. Solo usa lo que está en la transcripción.
```

Los agentes que trae el repo (`resumen`, `analisis`) se copian al instalar si no
existen; edítalos o bórralos libremente. Para borrar un agente, borra su
archivo.

## Requisitos

- Linux con PipeWire/PulseAudio (`pactl`)
- `ffmpeg`, `python3`, `libnotify` (`notify-send`), opcional `zenity` (pide título)
- `whisper-cpp` (binario `whisper-cli`). En Arch el paquete `ggml` no trae
  backend: instala también `ggml-cpu` o `ggml-vulkan`.
- Un CLI de LLM. Por defecto `claude -p` (Claude Code). Cualquier comando que
  reciba el prompt como argumento y el texto por stdin sirve, por ejemplo:
  `RESUMEET_LLM="ollama run llama3"` (ollama ignora el argumento y lee stdin;
  ajusta a tu herramienta).

Los modelos (`large-v3-turbo`, 1.6 GB, y Silero VAD) se descargan solos la
primera vez, con versión fija y checksum verificado.

## Instalar

Como plugin de Omarchy:

```sh
omarchy plugin add https://github.com/CristoSolar/resumeet --enable
~/.config/omarchy/plugins/io.github.cristosolar.resumeet/install.sh   # binarios y agentes
```

Suelto, sin Omarchy (sin widget de barra, lo demás funciona igual):

```sh
git clone https://github.com/CristoSolar/resumeet
cd resumeet && ./install.sh
meet-rec --self-test     # graba 4 s y corre el pipeline entero
```

Atajo en Hyprland: `bind = SUPER SHIFT, R, exec, meet-rec`. En Omarchy (Lua):
`o.bind("SUPER + SHIFT + R", "Grabar reunion", "meet-rec")`.

## Desinstalar

```sh
omarchy plugin remove io.github.cristosolar.resumeet
rm -f ~/.local/bin/meet-rec ~/.local/bin/meet-merge ~/.local/bin/meet-view ~/.local/bin/resumeet
```

El plugin no escribe fuera de su propio directorio. Lo demás que crea resumeet
queda donde lo pusiste: agentes en `~/.config/resumeet/agents/`, grabaciones en
`~/Reuniones/`, modelos de whisper en `~/.local/share/whisper-models/`. Bórralos
a mano si tampoco los quieres.

## Variables

| Variable | Default | Uso |
|---|---|---|
| `MEET_REC_DIR` | `~/Reuniones` | dónde guardar |
| `RESUMEET_AGENTS` | `~/.config/resumeet/agents` | directorio de prompts |
| `RESUMEET_LLM` | `claude -p` | comando LLM |
| `RESUMEET_LANG` | `es` | idioma de transcripción para whisper |
| `RESUMEET_UI_LANG` | `$RESUMEET_LANG` | idioma del visor (`en` / `es`) |
| `MEET_VIEW_PORT` | `8765` | puerto del visor |
| `MEET_REC_MODEL` / `MEET_REC_VAD_MODEL` | `~/.local/share/whisper-models/...` | rutas de modelos |

## Aviso

Grabar a terceros tiene implicancias legales según jurisdicción. Avisar a los
participantes es responsabilidad de quien graba.

## Licencia

MIT
