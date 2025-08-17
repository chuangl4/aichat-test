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
# Make Ollama the default provider/model
default_provider: ollama
default_model: phi3:instruct
providers:
  ollama:
    type: ollama
    api_base: http://localhost:11434

# A strict system prompt for shell command synthesis
profiles:
  cmdgen:
    system: |
      You are a command generator. Output exactly ONE safe shell command on the first line.
      On the second line, start with '# ' and briefly explain.
      If destructive, propose a dry-run or safer alternative.
      Use portable POSIX tools when possible.
    options:
      temperature: 0.2

# Optional quick templates
prompts:
  largest:
    description: list N largest files under path
    content: |
      list the {{n|10}} largest files under {{path|.}} as a single shell command
  recent-logs:
    description: tar recent .log files
    content: |
      find .log files modified in the last {{days|2}} days and tar.gz them as one archive
YAML

# Few helpful aliases and shell integration
{
  echo 'alias ash="aichat --shell --profile cmdgen"'
  echo 'alias aich="aichat"'
} >> ~/.bashrc

echo "Setup complete."

