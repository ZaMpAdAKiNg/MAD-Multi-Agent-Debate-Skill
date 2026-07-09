# MAD — Skill de Debate Multiagente

**Idioma:** [English](README.md) | Português (Brasil)

Faça **Claude (Opus)** e **Codex (GPT)** debaterem a mesma questão de arquitetura em
rodadas adversariais — *propostas cegas → crítica adversarial → revisão → síntese* —
e depois use um juiz para consolidar o resultado.

O valor vem da **diversidade de modelo**: Claude e Codex falham de formas diferentes.
Onde os dois **discordam** é exatamente onde mora o trade-off ou risco real. A síntese
final não é "quem ganhou" — é **convergência (alta confiança) + divergências (sua
decisão)**.

O projeto entrega duas coisas com a mesma fonte da verdade:

- **`bin/mad`** — um engine Bash único.
- **`SKILL.md`** — um gatilho para um agente (Claude Code / Codex) invocar o engine.

## Protocolo (adaptativo)

| Fase | O que acontece |
|------|----------------|
| Round 0 | Os dois modelos respondem **às cegas** — nenhum vê a resposta do outro. |
| Round 1..N | Cada modelo **critica o outro adversarialmente** e revisa a própria posição. Para cedo quando convergem; caso contrário, roda até N rounds (padrão 2). |
| Síntese | Um juiz consolida: convergência / divergências / recomendação / riscos. |

## Requisitos

As duas CLIs precisam estar instaladas **e autenticadas** — essa é a barreira real de
entrada, não a instalação:

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) — fornece `claude`
- [Codex CLI](https://github.com/openai/codex) — fornece `codex`

O engine é um script Bash em estilo POSIX. Ele roda onde Bash roda: macOS, Linux e
Windows via WSL2 ou Git Bash.

## Instalação

```bash
git clone https://github.com/ZaMpAdAKiNg/MAD-Multi-Agent-Debate-Skill.git
cd MAD-Multi-Agent-Debate-Skill
./install.sh
```

`install.sh` é não destrutivo: cria um symlink de `bin/mad` em `~/.local/bin`, verifica
se o diretório está no seu `PATH`, confere se as duas CLIs estão acessíveis e **imprime**
(sem copiar automaticamente) a linha para conectar o `SKILL.md` ao runtime do seu agente.

### Notas por plataforma

<details>
<summary><strong>macOS</strong></summary>

```bash
git clone https://github.com/ZaMpAdAKiNg/MAD-Multi-Agent-Debate-Skill.git && cd MAD-Multi-Agent-Debate-Skill
./install.sh
```

O macOS não inclui `~/.local/bin` no `PATH` por padrão. Se o instalador avisar isso,
adicione ao `~/.zshrc` (ou `~/.bash_profile`) e reinicie o shell:

```bash
export PATH="$HOME/.local/bin:$PATH"
```
</details>

<details>
<summary><strong>Ubuntu / Linux</strong></summary>

```bash
sudo apt-get update && sudo apt-get install -y git      # se necessário
git clone https://github.com/ZaMpAdAKiNg/MAD-Multi-Agent-Debate-Skill.git && cd MAD-Multi-Agent-Debate-Skill
./install.sh
```

Na maioria das distros, `~/.local/bin` já está no `PATH`. Se o instalador disser o
contrário, adicione ao `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```
</details>

<details>
<summary><strong>Windows</strong></summary>

O engine precisa de um ambiente Bash. Há dois caminhos suportados:

**WSL2 (recomendado).** Instale as duas CLIs *dentro* da sua distro Linux e siga os
passos de Ubuntu acima:

```powershell
wsl --install        # apenas na primeira vez, depois reinicie
```

```bash
# dentro do shell WSL2
git clone https://github.com/ZaMpAdAKiNg/MAD-Multi-Agent-Debate-Skill.git && cd MAD-Multi-Agent-Debate-Skill
./install.sh
```

**Git Bash (alternativa).** No shell Git Bash:

```bash
git clone https://github.com/ZaMpAdAKiNg/MAD-Multi-Agent-Debate-Skill.git && cd MAD-Multi-Agent-Debate-Skill
MAD_BIN_DIR="$HOME/bin" ./install.sh
```

Garanta que `claude` e `codex` estejam acessíveis na mesma sessão Bash e que o diretório
de instalação esteja no `PATH`. No Git Bash, `ln -s` pode copiar o arquivo em vez de
criar um symlink real; para atualizar depois, remova a cópia instalada antes (ou rode com
`MSYS=winsymlinks:nativestrict ./install.sh`). PowerShell/CMD nativos **não** são
suportados — rode `mad` pelo WSL2 ou Git Bash.
</details>

## Habilitar a skill (Claude Code e Codex)

`SKILL.md` é um arquivo de skill com YAML front-matter — o **mesmo arquivo funciona no
Claude Code e no Codex**, que compartilham o formato de skill. `install.sh` imprime estas
linhas; você também pode conectar manualmente:

```bash
# Claude Code (skills globais)
mkdir -p ~/.claude/skills/mad && ln -sf "$PWD/SKILL.md" ~/.claude/skills/mad/SKILL.md

# Codex (skills globais)
mkdir -p ~/.codex/skills/mad && ln -sf "$PWD/SKILL.md" ~/.codex/skills/mad/SKILL.md
```

O diretório exato de skills pode variar por versão/runtime — confira o seu primeiro.
Depois de conectado, peça para qualquer agente rodar *"mad &lt;sua questão de
arquitetura&gt;"* e ele invoca o engine.

## Uso

```bash
mad "Devo usar event-sourcing ou CRUD no módulo de pedidos?"
mad -f question.md              # questão vinda de arquivo
echo "monolito ou serviços?" | mad
mad --rounds 1 "..."            # debate raso (uma rodada de crítica)
MAD_DRY_RUN=1 mad "..."         # simulação — não gasta tokens, exercita o fluxo
MAD_LANG=pt mad "..."           # roda o debate em português
```

`stdout` é a síntese final. O transcript completo, round a round, fica salvo em
`$MAD_DEBATE_DIR/<timestamp>-<slug>/` para você ler o debate cru — o juiz tem leve viés
para o próprio lado, então o transcript é o tira-teima.

## Configuração (env)

| Var | Padrão | Significado |
|-----|--------|-------------|
| `MAD_LANG` | `en` | idioma dos prompts (`en` ou `pt`) |
| `MAD_OWNER` | `decision-maker` | como o juiz chama quem decide |
| `MAD_JUDGE` | `claude` | quem escreve a síntese (`codex` para inverter) |
| `MAD_CLAUDE_MODEL` / `MAD_CODEX_MODEL` | default da sessão | modelo de cada lado |
| `MAD_CLAUDE_BIN` / `MAD_CODEX_BIN` | `claude` / `codex` | nomes/caminhos dos binários |
| `MAD_DEBATE_DIR` | `${XDG_DATA_HOME:-~/.local/share}/mad/debates` | onde os transcripts ficam |

Os prompts vêm em inglês e português (os dois modelos são bilíngues); defina `MAD_LANG`
ou edite `bin/mad` para adicionar outro idioma.

## Quando *não* usar

Decisões triviais, tarefas de implementação direta ou qualquer coisa que uma opinião só
resolve. MAD é caro (dois modelos, várias rodadas). Reserve para decisões de arquitetura
que custam caro quando erradas.

## Licença

MIT © ZaMpA
