# Conditional Execution

Sake allows you to define conditions under which a command will be skipped. This is useful when you want to avoid running a command in certain scenarios. The `skipIf` closure receives the command context (arguments and environment) and returns `true` if the command should be skipped.

For example:

```swift
Command(
    description: "Deploy the project",
    skipIf: { context in
        // Skip the command if deployment is not needed
        return !shouldDeploy()
    }
) { _ in
    print("Deploying the project...")
}
```

In this example, the `deploy` command will only run if the `shouldDeploy()` function returns `true`.
