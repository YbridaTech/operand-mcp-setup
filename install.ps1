# Script de Instalação Automática do MCP Operand (Windows)
$ErrorActionPreference = "Continue"

Write-Host "=== Configurando MCP do Operand ===" -ForegroundColor Cyan

# 1. Garantir que nenhuma variável BROWSER da IDE intercepte para navegador interno
$env:BROWSER = ""

# 2. Limpar cache corrompido do npx (se existir) e instalar mcp-remote globalmente
$npxCache = Join-Path $env:LOCALAPPDATA "npm-cache\_npx"
if (Test-Path $npxCache) {
    Remove-Item -Recurse -Force $npxCache -ErrorAction SilentlyContinue
}

Write-Host "[1/3] Instalando ponte mcp-remote..." -ForegroundColor Yellow
npm install -g mcp-remote

# 3. Atualizar ~/.gemini/config/mcp_config.json (Antigravity) sem apagar outros servidores
Write-Host "[2/3] Configurando mcp_config.json no Antigravity..." -ForegroundColor Yellow
$configDir = Join-Path $env:USERPROFILE ".gemini\config"
$configFile = Join-Path $configDir "mcp_config.json"

if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

if (Test-Path $configFile) {
    try {
        $config = Get-Content $configFile -Raw | ConvertFrom-Json
    } catch {
        $config = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
    }
} else {
    $config = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
}

if (-not $config.mcpServers) {
    $config | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value ([PSCustomObject]@{}) -Force
}

$operandServer = [PSCustomObject]@{
    command = "npx"
    args    = @("-y", "mcp-remote", "https://mcp.operand.com.br/mcp/operand")
    env     = [PSCustomObject]@{ BROWSER = "" }
}

$config.mcpServers | Add-Member -MemberType NoteProperty -Name "operand" -Value $operandServer -Force
$config | ConvertTo-Json -Depth 10 | Set-Content $configFile -Encoding UTF8

Write-Host "Configuração salva em: $configFile" -ForegroundColor Green

# 4. Iniciar autenticação no navegador EXTERNO padrão do Windows
Write-Host "[3/3] Iniciando autenticação no seu navegador externo padrão (Chrome/Edge/Brave)..." -ForegroundColor Yellow
Write-Host "IMPORTANTE: Conclua o login na janela do navegador EXTERNO que se abrirá (NÃO use o navegador interno da IDE)." -ForegroundColor Magenta
Write-Host "Após colar o Token e ver 'Proxy established successfully' abaixo, pressione Ctrl+C e reinicie o Antigravity." -ForegroundColor Cyan

cmd.exe /c "set BROWSER=&& mcp-remote https://mcp.operand.com.br/mcp/operand"
