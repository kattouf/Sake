# Experimental Features

Sake includes experimental features that are disabled by default but can be enabled for testing and early access to new functionality.

::: warning Experimental Features
Experimental features are subject to change and may not be stable. Use them at your own risk in production environments.
:::

## Enabling Experimental Features

To enable experimental features, set the `SAKE_EXPERIMENTAL_FEATURES` environment variable:

```bash
export SAKE_EXPERIMENTAL_FEATURES=1
```

You can also set it for a single command:

```bash
SAKE_EXPERIMENTAL_FEATURES=1 sake your-command
```

## Available Experimental Features

### Swift Syntax Prebuilts

When experimental features are enabled, Sake uses [Swift Syntax prebuilts](https://forums.swift.org/t/preview-swift-syntax-prebuilts-for-macros/80202) to **significantly** improve SakeApp compilation times.

**Requirements:**
- **Swift 6.1.1** or higher (recommended)
- macOS 13+ or compatible Linux distribution

## Feedback

If you encounter issues with experimental features or have suggestions for improvements, please [open an issue](https://github.com/kattouf/Sake/issues) on GitHub.
