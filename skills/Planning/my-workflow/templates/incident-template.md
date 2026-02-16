# Incident Report: {Brief Description}

**Date**: {YYYY-MM-DD}
**Feature**: {feature name or "N/A"}
**Severity**: {critical / major / minor}
**Status**: {open / resolved / deferred}

## Summary

{2-3 sentence synthesis of what happened and why.}

## What Happened

{Factual description of the incident. What broke, when, how it was discovered. Include relevant git history.}

## Root Cause

{Five Whys analysis:}

```text
Why 1: {symptom} → Because {immediate cause}
Why 2: {immediate cause} → Because {deeper cause}
[Continue until root cause reached]

Root Cause: {the fundamental issue to fix}
```

## Impact

{What was affected, scope of impact, duration.}

## Affected Artifacts

| File/Component                | Impact                                 |
|-------------------------------|----------------------------------------|
| {file or component path}      | {description of how it was affected}   |

## Resolution

{What was done to fix the issue, or "Pending" / "Deferred to backlog."}

## Prevention

- [ ] {Action to prevent recurrence}
- [ ] {Systemic improvement}

## Lessons Learned

- {What we learned from this incident}
