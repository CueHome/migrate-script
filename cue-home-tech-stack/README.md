# Cue Home Tech Stack

Home workspace for Claude Code sessions working on CueHome's tech stack, fleet
operations, and DevOps AI-agents strategy.

**Start here:** [`CLAUDE.md`](./CLAUDE.md) — context + conventions every session reads first.

## Layout

```
.
├── CLAUDE.md                       # context & working conventions (read first)
├── .claude/
│   ├── settings.json               # permissions, env, project settings
│   └── hooks/session-start.sh      # prints workspace context at session start
├── docs/
│   ├── tech-stack/                 # one file per layer of the stack
│   │   └── overview.md             # index — start documenting here
│   ├── architecture/               # system context & diagrams
│   └── runbooks/                   # operational procedures (e.g. device migration)
├── strategy/
│   └── devops-ai-agents/           # discovery, agent roadmap, guardrails
└── scratch/                        # throwaway working files (git-ignored)
```

## Using this as your Claude Code home

1. Open a terminal in this folder.
2. Run `claude` (Claude Code CLI) — it auto-loads `CLAUDE.md` and `.claude/settings.json`.
3. Every session now shares the same context and conventions.
