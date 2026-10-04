# evren

A small command-line client for the **EVREN LLM API** (OpenAI-compatible endpoint
at `https://evren-llmapi.ssyz.org.tr/v1`). Single Python file, one dependency (`httpx`),
built for macOS and zsh.

> **Unofficial.** This is a community tool. It is not affiliated with or endorsed by
> the operators of the EVREN platform. You need your own EVREN API key.

## Features

- `evren "question"` for quick questions (reads stdin too: `cat notes.txt | evren "summarize"`)
- `evren chat` interactive chat with history
- `evren img photo.jpg "what is in this image?"` image questions (multiple images supported)
- `evren ocr scan.png` text extraction (`dots-ocr`, `deepseek-ocr-2`)
- `evren transcribe talk.m4a -l tr` speech to text (`qwen3-asr-1.7b`)
- `evren models`, `setmodel`, `whichmodel` to manage defaults
- `evren quota`, `evren doctor`, `evren terms`
- The answer goes to stdout (pipe-friendly); thinking text is hidden by default and shown dimmed on stderr with `--think` or `--show-thinking`
- After each request: time, first-token latency, token usage and remaining daily quota on stderr
- Clear error messages for 401, 403 (terms), 429 (quota), 503 (busy) and empty answers

## Install

Requirements: macOS, Python 3.9+.

```bash
git clone https://github.com/mustafacoshkun/evren.git
cd evren
bash install.sh
```

The installer creates a virtualenv at `~/.venvs/evren`, installs `httpx`, copies the
script to `~/bin/evren` and adds `~/bin` to your `PATH` in `~/.zshrc` if needed.
Open a new terminal afterwards.

## API key

The key is never stored in the script. It is read from, in this order:

1. The `EVRENAPI` environment variable
2. The macOS Keychain (service name `evren`)

Environment variable (add to `~/.zshrc`):

```bash
export EVRENAPI="evren_llm_..."
```

Keychain (prompts for the key, nothing lands in your shell history):

```bash
security add-generic-password -a "$USER" -s evren -w
```

Check everything with `evren doctor`.

## Usage

```bash
evren "Explain what a vector database is in two sentences"
evren -m deepseek-v4.1-flash --think -t 4096 "Prove that sqrt(2) is irrational"
evren --stream "Write a haiku about Ankara"
evren img a.jpg b.png "what changed between these two?"
evren ocr invoice.png -o invoice.txt
evren transcribe meeting.m4a -l tr -f srt -o meeting.srt
evren chat
```

Responses are returned in one piece by default. Add `--stream` to see them as they are generated.

### Models

```bash
evren models            # task, inputs, context size, which ones are your defaults
evren setmodel glm-5.3
evren setmodel --vision gemma-4-31b
evren setmodel --ocr dots-ocr
evren setmodel --asr qwen3-asr-1.7b
evren whichmodel
```

Priority: `-m` flag, then `EVREN_MODEL` (or `EVREN_VISION_MODEL`, `EVREN_OCR_MODEL`,
`EVREN_ASR_MODEL`), then `~/.config/evren/config.json`, then the built-in default.

### Terms of use

EVREN requires a one-time acceptance of its terms per account. `evren terms` shows the
status. Acceptance (`evren terms accept --version N`) is always an explicit, interactive
step; the tool never accepts on your behalf.

## Notes and known quirks

- Reasoning models share one `max_tokens` budget between thinking and the answer. If the
  answer comes back empty, raise `-t` (the tool warns you).
- `ocr` accepts images only (jpg, png, webp, gif, heic). Dense screenshots can send the
  OCR model into a repetition loop; the tool warns when the output looks like that.
- Large images are shrunk to 2048 px with the built-in macOS `sips` tool (disable with `--no-resize`).
- Very large audio files may be rejected. The server has a separate `/media` upload flow
  that this tool does not use yet.
- Model names, limits and prices change. Run `evren models` for the current list.

## License

MIT, see [LICENSE](LICENSE).
