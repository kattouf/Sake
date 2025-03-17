# Editing Commands

All commands in Sake are part of the Swift Package Manager (SPM) package called **SakeApp**, which is created when you [initialize a Sake project](/getting-started). You can find **SakeApp** in the root directory of your project.

### Opening SakeApp in Xcode

The easiest way to edit your Sake commands is to use the built-in `sake edit` command, which will open the SakeApp package in Xcode:

```bash
sake edit
```

This command automatically launches Xcode with your SakeApp project loaded, ready for editing.

### Manual Editing

Alternatively, you can open the **SakeApp** package manually in your preferred code editor and make the necessary modifications. You can add new commands, modify existing ones, or refactor command logic using the familiar tools and workflows that you use for any other Swift project.

After making changes to your commands, Sake will automatically rebuild the project the next time you run a command, ensuring that your modifications are applied.
