# Operand MCP: guia de configuração

Este guia conecta o **Operand** a assistentes de IA desktop (Antigravity, Claude Desktop, Cursor, VS Code etc.) usando o servidor MCP oficial:

```
https://mcp.operand.com.br/mcp/operand
```

Depois de conectado, você consulta, cria e atualiza **jobs, tarefas e projetos** conversando com a IA.

---

> ### 🤖 Instruções para o Agente de IA (se você pediu para a IA configurar por este link)
> Se você é um assistente de IA (Antigravity, Cursor, Windsurf, Claude Code) executando este guia para o usuário:
> 1. Instale globalmente: `npm install -g mcp-remote`
> 2. Adicione o servidor `operand` no `mcp_config.json` incluindo `"env": { "BROWSER": "" }` (sem apagar os servidores existentes).
> 3. Inicie a autenticação com a variável `BROWSER` vazia (`cmd.exe /c "set BROWSER=&& mcp-remote https://mcp.operand.com.br/mcp/operand"` no Windows ou `BROWSER="" mcp-remote https://mcp.operand.com.br/mcp/operand` no macOS/Linux).
> 4. **REGRA CRÍTICA DE NAVEGADOR EXTERNO:**
>    - O `mcp-remote` **já abre automaticamente** a janela de autenticação no **navegador externo padrão do sistema** (Chrome, Edge, Safari, Brave).
>    - **NUNCA** abra a URL de autenticação no navegador interno da IDE (*built-in browser*) e **NÃO** envie o link OAuth como link clicável no chat da IDE (pois clicar no link dentro do chat abre o navegador interno da IDE, que bloqueia o callback `http://127.0.0.1` / cookies `SameSite=Lax` e invalida a sessão).
>    - Caso precise forçar a abertura manualmente no navegador externo do sistema, use `explorer.exe "<url>"` no Windows ou `open "<url>"` no macOS — ou envie a URL apenas dentro de um bloco de código (texto copiável) pedindo para o usuário colar no Chrome/Edge/Safari.
> 5. Assim que o log mostrar `Proxy established successfully`, encerre o processo temporário do `mcp-remote` e avise o usuário que está pronto.

---

## ⚡ Opção Rápida: Instalação com 1 comando (abre direto no navegador externo)

Antes de rodar, tenha em mãos o seu **Token da API Operand** (gerado no Operand em **Configurações → Integrações → MCP**).

**No Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/YbridaTech/operand-mcp-setup/main/install.ps1 | iex
```

**No macOS / Linux (Terminal):**
```bash
curl -fsSL https://raw.githubusercontent.com/YbridaTech/operand-mcp-setup/main/install.sh | bash
```

O script instala o `mcp-remote`, adiciona a configuração no Antigravity sem apagar seus outros MCPs e já abre a tela de login **no seu navegador externo padrão** (Chrome/Edge/Safari).

---

## 🛠️ Opção Manual (Passo a Passo)

### 1. Pré-requisitos

- **Node.js 18+** instalado ([nodejs.org](https://nodejs.org)). Para conferir: `node -v`
- **Token da API Operand**: no Operand, vá em **Configurações → Integrações → MCP** e gere o seu token.

> ⚠️ O token é pessoal. A IA só vê e altera o que o **seu usuário** já tem permissão para ver e alterar no Operand. **Nunca compartilhe o seu token nem o coloque em arquivos versionados.**

---

### 2. Instalar a ponte `mcp-remote` (recomendado)

O servidor do Operand usa autenticação OAuth. Apps desktop se conectam a ele pela ponte `mcp-remote`:

```bash
npm install -g mcp-remote
```

> A instalação global evita erros de cache do `npx` no Windows (`ERR_INVALID_PACKAGE_CONFIG`).

---

### 3. Configurar o seu app

Adicione o bloco `operand` dentro de `mcpServers` no arquivo de configuração do seu app. **Se o arquivo já tiver outros servidores, não apague os existentes. Só acrescente o novo bloco.**

O campo `"env": { "BROWSER": "" }` garante que a IDE sempre acione o **navegador externo do sistema** e nunca tente abrir o login no navegador interno do app:

```json
{
  "mcpServers": {
    "operand": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.operand.com.br/mcp/operand"
      ],
      "env": {
        "BROWSER": ""
      }
    }
  }
}
```

#### Onde fica o arquivo

| App | Caminho |
| --- | --- |
| **Antigravity** | Windows: `%USERPROFILE%\.gemini\config\mcp_config.json`<br>macOS/Linux: `~/.gemini/config/mcp_config.json` |
| **Claude Desktop** | Windows: `%APPDATA%\Claude\claude_desktop_config.json`<br>macOS: `~/Library/Application Support/Claude/claude_desktop_config.json` |
| **Cursor** | `~/.cursor/mcp.json` |
| **VS Code** | `.vscode/mcp.json` (use a chave `"servers"` no lugar de `"mcpServers"`) |

---

### 4. Primeiro login (sempre no navegador externo)

Rode o comando abaixo no terminal para abrir a autorização diretamente no seu **navegador externo** (Chrome, Edge, Safari, Brave):

**Windows (CMD / PowerShell):**
```powershell
cmd.exe /c "set BROWSER=&& npx -y mcp-remote https://mcp.operand.com.br/mcp/operand"
```

**macOS / Linux:**
```bash
BROWSER="" npx -y mcp-remote https://mcp.operand.com.br/mcp/operand
```

1. Uma página **"Conectar ao Operand"** abrirá automaticamente no seu **navegador externo**. *(⚠️ Não clique no link pelo chat/terminal para não abrir no navegador interno da IDE — se não abrir sozinho, copie a URL do terminal e cole manualmente no Chrome/Edge/Safari).*
2. Cole o seu **Token da API Operand** e clique em **Continuar**.
3. No terminal aparecerá `Proxy established successfully`. Pronto! Pode fechar com `Ctrl+C`.

A sessão fica salva em `~/.mcp-auth/`, então não é preciso repetir o login.

Depois, **reinicie o app** (ou recarregue a janela) para ele carregar as ferramentas do Operand.

---

## 5. Testar

Peça para a IA, por exemplo:

- "Quais são os meus jobs no Operand?"
- "Quais tarefas eu tenho para amanhã?"
- "Crie uma tarefa de revisão no job #1234 para sexta."

---

## Solução de problemas

| Problema | Solução |
| --- | --- |
| **Erro ao tentar logar pelo navegador interno do Antigravity/IDE** | O navegador interno (*built-in browser*) bloqueia o redirecionamento `http://127.0.0.1` e os cookies de sessão do OAuth. Sempre faça a autenticação pelo **navegador externo** (Chrome, Edge, Safari, Brave). |
| `{"message":"Unauthenticated."}` | Login ainda não foi feito ou expirou. Rode o comando do passo 4. |
| `ERR_INVALID_PACKAGE_CONFIG` (Windows) | Apague `%LOCALAPPDATA%\npm-cache\_npx` e rode `npm install -g mcp-remote`. |
| Opção MCP não aparece no Operand | A empresa precisa ter a **API Pública** do Operand contratada. Fale com o admin. |
| Trocar de conta / token inválido | Apague a pasta `~/.mcp-auth` e refaça o passo 4. |
| Ferramentas não aparecem no app | Reinicie o app por completo depois de editar o JSON. |

---

## Limitações

- O **Timesheet** pode ter restrições de escrita via MCP.
- Todas as ações respeitam as permissões do seu usuário no Operand.
