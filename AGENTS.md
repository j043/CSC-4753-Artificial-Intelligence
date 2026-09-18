# Repository working instructions

## Preserve actual user prompts

The user requires a plain-text record of every prompt they give while working in this repository, across sessions.

- At the start of each user turn, before substantive work, append the user's actual message text to `A1/prompts.txt`. Include questions, corrections, and follow-up requests, not just implementation tasks. Append additional user messages received during ongoing work as well.
- Keep this path as the repository's active prompt log until the user explicitly chooses another location. It currently also serves the A1 assignment's development-prompt deliverable.
- Preserve the user's wording, spelling, and punctuation verbatim. Do not replace prompts with summaries or reconstructed quotations.
- Add a sequential entry number and the current date as metadata outside the quoted prompt text. Inspect the log's tail first to determine the next number and avoid logging the same message twice after resuming or compacting a session. Identical wording in a genuinely new message is a new entry.
- Include user-supplied textual acceptance criteria and task attachments, or reference an already-preserved verbatim copy. Exclude automatically injected IDE/environment context, system/developer instructions, assistant responses, and tool output.
- Append without rewriting or deleting existing entries. Preserve UTF-8 encoding. Never invent missing historical prompts; explicitly note any known gap.
- Do not copy credentials, API keys, passwords, or other secrets into the repository. If a prompt contains a secret, replace only the secret with `[REDACTED SECRET]` and label the entry as redacted.
- If logging fails, report it and retry when possible; do not claim the prompt was saved unless the write succeeded.
- Keep this instruction file and the prompt log with the repository so the convention is available in future sessions. Logging does not itself authorize commits, pushes, or sending the log elsewhere.
