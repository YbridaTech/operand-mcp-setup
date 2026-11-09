#!/usr/bin/env bash
set -e

echo "=== Configurando MCP do Operand ==="

# 1. Garantir que nenhuma variável BROWSER da IDE intercepte para navegador interno
unset BROWSER
export BROWSER=""

# 2. Instalar mcp-remote globalmente
echo "[1/3] Instalando ponte mcp-remote..."
npm install -g mcp-remote

# 3. Atualizar ~/.gemini/config/mcp_config.json (Antigravity) sem apagar outros servidores
echo "[2/3] Configurando mcp_config.json no Antigravity..."
CONFIG_DIR="$HOME/.gemini/config"
CONFIG_FILE="$CONFIG_DIR/mcp_config.json"

mkdir -p "$CONFIG_DIR"

node -e '
const fs = require("fs");
const file = process.argv[1];
let config = { mcpServers: {} };
if (fs.existsSync(file)) {
  try { config = JSON.parse(fs.readFileSync(file, "utf8")); } catch (e) {}
}
if (!config.mcpServers) config.mcpServers = {};
config.mcpServers.operand = {
  command: "npx",
  args: ["-y", "mcp-remote", "https://mcp.operand.com.br/mcp/operand"],
  env: { BROWSER: "" }
};
fs.writeFileSync(file, JSON.stringify(config, null, 2) + "\n", "utf8");
' "$CONFIG_FILE"

echo "Configuração salva em: $CONFIG_FILE"

# 4. Iniciar autenticação no navegador EXTERNO padrão do sistema
echo "[3/3] Iniciando autenticação no seu navegador externo padrão..."
echo "IMPORTANTE: Conclua o login na janela do navegador EXTERNO que se abrirá (NÃO use o navegador interno da IDE)."
echo "Após colar o Token e ver 'Proxy established successfully' abaixo, pressione Ctrl+C e reinicie o Antigravity."

BROWSER="" mcp-remote https://mcp.operand.com.br/mcp/operand
