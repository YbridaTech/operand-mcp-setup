# Operand MCP: guia de configuração

Este guia conecta o **Operand** a assistentes de IA desktop (Antigravity, Claude Desktop, Cursor, VS Code etc.) usando o servidor MCP oficial:

```
https://mcp.operand.com.br/mcp/operand
```

Depois de conectado, você consulta, cria e atualiza **jobs, tarefas e projetos** conversando com a IA.

---

## 1. Pré-requisitos

- **Node.js 18+** instalado ([nodejs.org](https://nodejs.org)). Para conferir: `node -v`
- **Token da API Operand**: no Operand, vá em **Configurações → Integrações → MCP** e gere o seu token.

> ⚠️ O token é pessoal. A IA só vê e altera o que o **seu usuário** já tem permissão para ver e alterar no Operand. **Nunca compartilhe o seu token nem o coloque em arquivos versionados.**

---

## 2. Instalar a ponte `mcp-remote` (recomendado)

O servidor do Operand usa autenticação OAuth. Apps desktop se conectam a ele pela ponte `mcp-remote`:

```bash
npm install -g mcp-remote
```

> A instalação global evita erros de cache do `npx` no Windows (`ERR_INVALID_PACKAGE_CONFIG`).

---

## 3. Configurar o seu app

Adicione o bloco `operand` dentro de `mcpServers` no arquivo de configuração do seu app. **Se o arquivo já tiver outros servidores, não apague os existentes. Só acrescente o novo bloco.**

```json
{
  "mcpServers": {
    "operand": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.operand.com.br/mcp/operand"
      ]
    }
  }
}
```

### Onde fica o arquivo

| App | Caminho |
| --- | --- |
| **Antigravity** | Windows: `%USERPROFILE%\.gemini\config\mcp_config.json`<br>macOS/Linux: `~/.gemini/config/mcp_config.json` |
| **Claude Desktop** | Windows: `%APPDATA%\Claude\claude_desktop_config.json`<br>macOS: `~/Library/Application Support/Claude/claude_desktop_config.json` |
| **Cursor** | `~/.cursor/mcp.json` |
| **VS Code** | `.vscode/mcp.json` (use a chave `"servers"` no lugar de `"mcpServers"`) |

---

## 4. Primeiro login (só na primeira vez)

Você pode deixar o app disparar o login sozinho ou rodar este comando no terminal:

```bash
npx -y mcp-remote https://mcp.operand.com.br/mcp/operand
```

1. Uma página **"Conectar ao Operand"** abre no navegador.
2. Cole o seu **Token da API Operand** e clique em **Continuar**.
3. No terminal aparece `Proxy established successfully`. Pronto! Pode fechar com `Ctrl+C`.

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
| `{"message":"Unauthenticated."}` | Login ainda não foi feito ou expirou. Rode o comando do passo 4. |
| `ERR_INVALID_PACKAGE_CONFIG` (Windows) | Apague `%LOCALAPPDATA%\npm-cache\_npx` e rode `npm install -g mcp-remote`. |
| Opção MCP não aparece no Operand | A empresa precisa ter a **API Pública** do Operand contratada. Fale com o admin. |
| Trocar de conta / token inválido | Apague a pasta `~/.mcp-auth` e refaça o passo 4. |
| Ferramentas não aparecem no app | Reinicie o app por completo depois de editar o JSON. |

---

## Limitações

- O **Timesheet** pode ter restrições de escrita via MCP.
- Todas as ações respeitam as permissões do seu usuário no Operand.
