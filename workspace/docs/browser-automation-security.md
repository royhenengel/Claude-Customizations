# Browser Automation Security

Security assessment for browser control via Claude Code. Three modes are configured (see MEMORY.md for usage).

## Risk Summary

| Risk | Chrome Integration | Playwright (extension) | Playwright (headed) |
| ---- | ------------------ | ---------------------- | ------------------- |
| Prompt injection | High (1-11% success with defenses) | Medium | Lower (isolated) |
| Session/token theft | Critical (confirmed) | High (real sessions) | Low |
| Unauthorized actions | High (soft guardrails only) | Medium | Medium |
| Data exfiltration | Critical (full page + network) | High | Medium |

## Key Findings

- **Claude in Chrome** (Anthropic): `debugger` permission gives full CDP access. Zenity Labs confirmed `read_network_requests` exposes OAuth tokens in-flight. Anthropic's own RL-trained attacker achieved 1-11% prompt injection success even with defenses.

- **Playwright MCP Bridge** (Microsoft): **CVE-2025-9611** (CVSS 7.2) - DNS rebinding attack allowed unauthorized tool invocation. Fixed in v0.0.40+.

- **Prompt injection is unsolved**: hidden text in HTML, white-on-white, HTML comments, image-embedded instructions. Non-zero success rate across all vendors.

- **Guardrails are behavioral, not technical**: Claude was demonstrated deviating from approved plans without additional authorization.

## Safety Rules

1. **Use a dedicated Chrome profile** for browser automation (no financial, email, or work-critical logins)
2. **Never use `--host 0.0.0.0`** (default localhost binding is correct)
3. **Prefer headed mode** (isolated) over extension mode unless you specifically need existing auth
4. **Avoid untrusted UGC pages** (Reddit, forums) in extension mode due to prompt injection surface
5. **Review actions before confirming** when Claude proposes browser interactions on sensitive sites

## Configuration

Config file: `~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/playwright/.mcp.json`

Both Playwright entries are `disabled: true` (lazy-loaded via ToolSearch). No persistent daemon. stdio transport (no open ports). Servers terminate when Claude Code session ends.

Chrome extensions required:
- [Claude in Chrome](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) (Anthropic)
- [Playwright MCP Bridge](https://chromewebstore.google.com/detail/playwright-mcp-bridge/mmlmfjhmonkocbjadbfplnigmagldckm) (Microsoft)

## References

- [Zenity Labs threat analysis](https://labs.zenity.io/p/claude-in-chrome-a-threat-analysis)
- [Anthropic prompt injection research](https://www.anthropic.com/research/prompt-injection-defenses)
- [CVE-2025-9611 (SentinelOne)](https://www.sentinelone.com/vulnerability-database/cve-2025-9611/)
- [Anthropic safety guide](https://support.claude.com/en/articles/12902428-using-claude-in-chrome-safely)
