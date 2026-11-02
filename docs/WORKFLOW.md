# How we work: developer and Claude

A reusable playbook for building an app with Claude from a design file. Nothing here is specific to ASPHYR, so it can be copied into any new project. To use it, ask Claude to read this file at the start of a session.

Keep this file about **how we work**. Project details belong elsewhere:
- **Design intent:** `DESIGN-DECISIONS.md`
- **Progress, technical rules and known issues:** `IMPLEMENTATION-NOTES.md`

## Who does what

| Developer | Claude |
|---|---|
| Decides scope, priorities and design direction | Inspects, proposes, implements and tests |
| Runs every commit, push, merge and branch command | Supplies the exact commands, one step at a time, and never runs them |
| Reviews and approves each step | Stops after each step and waits for approval |
| Owns the design file | Reads the design file, and doesn't edit it unless asked |

## Working rules

1. **Inspect before changing.** The first session on an existing project is read-only. Claude reports the architecture, design system and issues by severity, plus anything it could not verify.
2. **One step per branch.** Each screen or concern gets its own branch, and it reaches `main` only after approval.
3. **Stay in scope.** Claude changes only the files that belong to the current step. Anything else it notices gets reported, not fixed.
4. **Never move on without approval.** "Done" means handing work over for review, not starting the next step.
5. **Suggest like a senior developer.** Claude gives a recommendation and its trade-offs, and the developer decides.
6. **Report honestly.** Separate what was tested from what was inferred. Say what was not tested. Correct earlier mistakes openly.
7. **Keep the notes current.** Update the notes on the same branch as the work they describe.

## The cycle for each step

1. **Plan the step.** Claude says what it will change and flags any decisions.
2. **Create the branch.** The developer runs the command and tells Claude to begin.
3. **Compare with the design.** Claude reads the design specs, not just a picture of them.
4. **Implement.** Reuse existing components and tokens where possible.
5. **Verify in the running app.**
   - Build it, and read the warnings.
   - Walk every affected flow, including back navigation.
   - Measure the screen against the design render instead of judging by eye.
   - Check logs and crash reports.
   - After any further code change, retest what it touched.
6. **Hand over.** Claude reports the results, what wasn't tested, and the review and commit commands.
7. **Review and test.** The developer checks it and asks questions.
8. **Commit and push.** The developer runs the commands.
9. **Merge.** The developer merges to `main`, and Claude confirms the result.

## Git commands for each step

```bash
git switch -c fix/short-description    # start the step
git diff -w                            # review, ignoring re-indentation
git add <only this step's files>       # stage
git status                             # confirm what is staged
git commit -m "type(scope): summary"   # commit
git push -u origin fix/short-description
git switch main                        # after approval
git pull
git merge --ff-only fix/short-description
git push
git log --oneline -3                   # confirm
```

Commit messages follow Conventional Commits: `feat`, `fix`, `refactor`, `docs`, `chore`.

## Lessons learned

- **Test a staged migration before promising it.** A plan to convert screens one at a time failed because old and new navigation patterns could not coexist. A build that compiles can still crash at runtime.
- **Find the root cause before fixing.** Read the crash report, reproduce the bug, and change one thing at a time. Revert experiments afterwards.
- **Keep structural and visual changes on separate branches.** Either can then be reviewed or reverted on its own.
- **Measure design differences.** Pixel measurements caught a 14pt offset, a font mismatch and a gradient difference that looked fine by eye.
- **Confirm the design tool's exact font version.** The same font name can have different versions and cuts with different widths. Check the font's settings in the design file, then measure candidates before installing one.
- **Test at large text sizes.** Layouts that are perfect at the default size can truncate important copy.
- **Check the docs against the design.** When the two disagree, raise it and let the developer decide.
- **Leave test setups as you found them.** Restore Simulator settings and shut down extra devices.

## Starting a new project with Claude

Paste this at the start of the first session, adjusting it as needed:

> Read `docs/WORKFLOW.md` and follow it. This is a read-only inspection first: don't change, create or delete project files. Report the architecture, design system, issues by severity, and anything you couldn't verify. I run all git commands myself, so give me the exact commands step by step. Don't start a step without my approval. Design file: `<link>`.
