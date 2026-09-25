# TraeX operating layer

The installer embeds this layer and the shared engineering contract in the
active TRAE_HOME/AGENTS.md (or AGENTS.override.md). TraeX does not expand Claude
@ imports. Do not reread AGENTS.yct.md or CLAUDE.yct.md in a business checkout.
Detailed methods are beside this file as METHODS.yct.md; load only a needed
method. The active instruction paths in the conversation take precedence.

Use the installed Markdown roles in TRAE_HOME/agents. They are rendered from
this package's role contracts. New roles inherit the active model; upgrades
preserve local model and effort choices, including model: inherit.
Do not infer the actual model from the requested role; use runtime evidence.
If a model is unavailable, use one suitable available role or parent execution
with equivalent scope and required independence. Do not retry the same failed
model or create an unconditional chain of reviewers.
After confirmed Transport closed, do not keep querying that connection. Use a
supported reconnect once or continue through an available route; a new query
or a healthy external doctor does not repair the current client transport.

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
For an explicitly time-bounded run, enforce the deadline on the owned outer
command, including model startup and tool dispatch. yield_time_ms is only a
poll interval. At the deadline, stop and reconcile owned work; a started TraeX
session with no runner invocation is not an executed product Case.
After consuming a completed child, retain it only for an identified follow-up.
Use a close/shutdown tool only if this runtime exposes one; interrupt_agent
stops a turn and leaves the child available, so it is not a close substitute.
A completed entry in list_agents does not by itself prove slot or process
retention. When no close tool exists, rely on runtime admission/cleanup and
report that boundary instead of deleting session history or repeatedly polling.

The parent validates the requested artifact and behavior, not a worker's
receipt label. A local diagnostic run cannot satisfy an acceptance criterion
requiring the installed product or a remote production entrypoint. If a child
returns only intentions or setup, continue the authorized remainder. Missing
credentials block the dependent path; finish independent work and report the
precise missing input without inventing success.

Keep code-mode orchestration small. Use structured tool arguments for data and
direct patches for edits. Build JSON from an object with a serializer, not by
interpolating multiline prose into a JSON string. A quoted shell heredoc prevents
shell expansion but does not JSON-escape newlines, quotes or backslashes. For an
stdin-only command, serialize in the orchestrator and pass that text through an
unexpanded heredoc with a delimiter absent from the payload; do not create files
or additional commands when that entrypoint forbids them. JSON serialization
does not quote shell arguments.
For substantial shell/Python work, use a small script or quoted interpreter
heredoc rather than nested shell -c / node -e strings. Pass patch text directly,
never copied terminal color escapes; preserve literal backticks and dollar signs
through every interpreter layer. Keep optional searches separate from required
reads so an ordinary no-match exit cannot skip them. Use task-specific variable
names such as check_exit, not shell-owned names such as zsh status.
Do not shadow runtime helpers such as text, tools, image, store or load.
After a wrapper syntax error, simplify the invocation. After a patch-context
failure, read the affected current range before preparing the corrected patch.
A wrapper can fail after a command or write succeeded: inspect its nested
terminal result and actual output before retrying, and repeat only unfinished
work. This includes passing tests: read their saved terminal result after a
reporting error instead of rerunning them. Do not rerun a successful side effect.
Use Git checks only in a confirmed Git worktree. For an artifact-only task,
verify the requested files directly; Git status/diff is not a universal check.
