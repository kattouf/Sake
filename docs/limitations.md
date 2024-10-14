# Limitations

When using Sake, there are some important limitations to be aware of:

- **CTRL+C Behavior**: Stopping nested commands using `CTRL+C` does not always work as expected. These commands may continue running in the background, and stopping them manually might be necessary.

- **Interactive Commands**: Interactive commands, such as prompts requiring user input, are not supported. Implementing such functionality in Swift is non-trivial, and existing third-party solutions do not provide out-of-the-box support for this feature.
