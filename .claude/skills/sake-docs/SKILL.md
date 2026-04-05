---
name: sake-docs
description: Use when writing or updating Sake documentation — VitePress site structure, existing pages, how to add new docs, documentation conventions.
---

# Sake Documentation

Documentation site: [sakeswift.org](https://sakeswift.org), built with VitePress, deployed via GitHub Pages.

## Directory Structure

All docs in `docs/`. Key files:

```
docs/
  index.md                          — landing page
  about.md                          — what Sake is
  installation.md                   — brew, mint, mise
  getting-started.md                — sake init, first command
  how-it-works.md                   — sake vs SakeApp architecture
  editing-commands.md               — sake edit, manual editing
  commands-basic-rules.md           — visibility, static, type rules
  commands-dependencies.md          — deps, concurrent, CommandRunner
  commands-conditional-execution.md — skipIf
  commands-grouping.md              — @CommandGroup, SakeAppConfiguration
  commands-name-conversions.md      — case strategies
  commands-run-context.md           — Context properties, mapArguments/mapEnvironment
  passing-arguments.md              — basic argument passing
  sharing-data-between-commands.md  — context.storage
  interruption-handling.md          — InterruptionHandler, SIGINT cleanup
  advanced-argument-parsing.md      — ArgumentParser integration
  advanced-cli-tools-running.md     — swift-subprocess usage
  advanced-extensibility-of-sakeapp.md — adding SPM dependencies
  advanced-usage-example.md         — lint + ensureInstalled example
  configuration.md                  — CLI/ENV/.sake.yml cascade
  continuous-integration.md         — prebuilding, caching, setup-sake action
  shell-completion.md               — zsh/fig completion
  experimental-features.md          — SAKE_EXPERIMENTAL_FEATURES, swift-syntax prebuilts
  troubleshooting.md                — sake clean, rm -rf SakeApp/.build
  contribution-guide.md             — formatting, testing, conventional commits
  package.json                      — VitePress config
```

## VitePress Build

```bash
cd docs && npm ci && npm run docs:build
```

Deployed automatically on push to main (docs/** changes) via `.github/workflows/docs-deploy.yml`.

## Documentation Conventions

- VitePress markdown with `::: tip`, `::: warning`, `::: info` containers
- Code blocks with language + optional line highlighting: ````swift {4}````
- `outline: deep` frontmatter for deep table of contents
- External tutorial links in tip blocks (Getting Started references swifttoolkit.dev articles)
- Docs reference each other via relative paths: `[Configuration](/configuration)`

## Adding a New Doc

1. Create `docs/new-page.md`
2. Add to VitePress sidebar config in `docs/.vitepress/config.js` (if it exists) or navigation
3. Cross-reference from related pages
4. Run `cd docs && npm run docs:dev` to preview locally

## Tone

- Practical, example-driven
- Short explanations → code example → explanation of what the code does
- "In this example..." pattern for walkthroughs
