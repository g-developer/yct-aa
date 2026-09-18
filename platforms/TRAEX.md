# TraeX operating layer

The installer embeds this layer and the shared engineering contract in the
active TRAE_HOME/AGENTS.md (or AGENTS.override.md). TraeX does not expand Claude
@ imports. Do not reread AGENTS.yct.md or CLAUDE.yct.md in a business checkout.
Detailed methods are beside this file as METHODS.yct.md; load only a needed
method. The active instruction paths in the conversation take precedence.

Use the installed Markdown roles in TRAE_HOME/agents. They are rendered from
this package's Codex role contracts, with explicit TraeX model names and effort.
Do not infer the actual model from the requested role; use runtime evidence.
If a model is unavailable, use one suitable available role or parent execution
with equivalent scope and required independence. Do not retry the same failed
model or create an unconditional chain of reviewers.

Shortcut skills share one canonical directory with the Codex installation;
TraeX links to that same directory so discovery cannot select an old second
copy. Use /yct-aa or $yct-aa. The active mode permits only useful delegation;
read-only diagnosis does not authorize source edits.

A packet contains the full absolute worktree, outcome, allowed changes and
check. Use fork_turns="none" for new agents. For an Agent tool without that
parameter, pass a self-contained prompt without conversation history. On every
follow-up, repeat the target worktree and remaining work. Check the child's
reported worktree before using its results. Role files are not business cwd.

Do not start extra agents or shell sessions just to fill capacity. When a
finite process is still running, collect its terminal output. If capacity is
exhausted, reconcile owned work before admission; never kill another session's
processes by name. A status question does not cancel the active goal.

The parent validates the requested artifact and behavior, not a worker's
receipt label. A local diagnostic run cannot satisfy an acceptance criterion
requiring the installed product or a remote production entrypoint. If a child
returns only intentions or setup, continue the authorized remainder. Missing
credentials block the dependent path; finish independent work and report the
precise missing input without inventing success.
