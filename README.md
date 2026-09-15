# resumeet

Graba reuniones (Meet, Zoom, lo que suene en el sistema), las transcribe en
local con whisper.cpp y corre **agentes** (prompts en `.md`) sobre la
transcripción: resumen, pasos a seguir, o lo que cada usuario quiera.

Todo corre en tu máquina. Solo el paso de agentes llama a un LLM, y ese
comando lo eliges tú.

## Cómo funciona

```
atajo ──> meet-rec (toggle)
            │ start: ffmpeg graba mic y audio del sistema en 2 pistas WAV 16 kHz
            │ stop:  whisper-cli x2 (con VAD) → meet-merge → transcripcion.md
            │        por cada ~/.config/resumeet/agents/<nombre>.md
            │          $RESUMEET_LLM "<prompt>" < transcripcion.md > <nombre>.md
            └─> notificación "Reunión lista"
```

Dos pistas separadas dan separación de hablante (`Yo` / `Ellos`) sin
diarización. El VAD (Silero) es obligatorio: sin él Whisper alucina frases
sobre los silencios, que son la mayoría de cada pista.

Salida en `~/Reuniones/2026-09-15_1130/`: `mic.wav`, `remoto.wav`,
`transcripcion.md`, y un `.md` por agente.

## Requisitos

- Linux con PipeWire/PulseAudio (`pactl`)
- `ffmpeg`, `python3`, `libnotify` (`notify-send`), opcional `zenity` (pide título)
- `whisper-cpp` (binario `whisper-cli`). En Arch el paquete `ggml` no trae
  backend: instala también `ggml-cpu` o `ggml-vulkan`.
- Un CLI de LLM. Por defecto `claude -p` (Claude Code). Cualquier comando que
  reciba el prompt como argumento y el texto por stdin sirve, por ejemplo:
  `RESUMEET_LLM="ollama run llama3"` (ollama ignora el argumento y lee stdin;
  ajusta a tu herramienta).

Los modelos (`large-v3-turbo` 1.6 GB y Silero VAD) se descargan solos la
primera vez.

## Instalar

```sh
git clone https://github.com/CristoSolar/resumeet
cd resumeet && ./install.sh
meet-rec --self-test     # graba 4 s y corre el pipeline entero
```

Atajo en Hyprland: `bind = SUPER SHIFT, R, exec, meet-rec`. En Omarchy (Lua):
`o.bind("SUPER + SHIFT + R", "Grabar reunion", "meet-rec")`.

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

Los agentes que trae el repo (`resumen`, `analisis`) se copian al instalar
si no existen; edítalos o bórralos libremente. Para borrar un agente, borra su
archivo.

## Variables

| Variable | Default | Uso |
|---|---|---|
| `MEET_REC_DIR` | `~/Reuniones` | dónde guardar |
| `RESUMEET_AGENTS` | `~/.config/resumeet/agents` | directorio de prompts |
| `RESUMEET_LLM` | `claude -p` | comando LLM |
| `RESUMEET_LANG` | `es` | idioma para whisper |
| `MEET_REC_MODEL` / `MEET_REC_VAD_MODEL` | `~/.local/share/whisper-models/...` | rutas de modelos |

## Comandos

```
meet-rec              alterna grabar/parar
meet-rec --status     estado actual
meet-rec --self-test  verifica el pipeline completo
```

## Aviso

Grabar a terceros tiene implicancias legales según jurisdicción. Avisar a los
participantes es responsabilidad de quien graba.

## Licencia

MIT
