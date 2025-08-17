#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y curl unzip python3-pip

# --- Ollama (local models) ---
if ! command -v ollama >/dev/null 2>&1; then
  curl -fsSL https://ollama.com/install.sh | sh
fi
(ollama serve &) >/dev/null 2>&1 || true
sleep 2

# Lightweight default model (swap if you prefer)
ollama pull phi3:instruct
# ollama pull qwen2.5:3b-instruct
# ollama pull llama3.2:3b-instruct

# --- AIChat ---
# Prefer single-file binary install
if ! command -v aichat >/dev/null 2>&1; then
  curl -fLo /tmp/aichat.tgz https://github.com/sigoden/aichat/releases/download/v0.30.0/aichat-v0.30.0-x86_64-unknown-linux-musl.tar.gz
  sudo tar -xzf /tmp/aichat.tgz -C /usr/local/bin aichat
  rm -f /tmp/aichat.tgz
fi

# AIChat config
mkdir -p ~/.config/aichat
cat > ~/.config/aichat/config.yaml <<'YAML'
model: ollama:phi3:instruct
clients:
  - type: openai-compatible
    name: ollama
    api_base: http://localhost:11434/v1
    models:
      - name: phi3:instruct
        max_input_tokens: 128000 # Example, adjust as needed based on phi3:instruct documentation
        supports_reasoning: true
YAML

# Few helpful aliases and shell integration
{
  echo 'alias ash="aichat --shell --profile cmdgen"'
  echo 'alias aich="aichat"'
} >> ~/.bashrc

echo "Setup complete."

