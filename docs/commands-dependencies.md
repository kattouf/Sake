---
outline: deep
---

# Dependencies

Sake allows you to define commands that must be run before the main command. Dependencies ensure that any prerequisite commands are executed in the correct order.

For example:

```swift
Command(
    description: "Build the project",
    dependencies: [clean],
    run: { _ in
        print("Building the project...")
    }
)
```

In this example, the `clean` command will always be executed before the `build` command. This ensures that the project is cleaned before building.

### Concurrently Execution

Sake also supports running dependencies in parallel to speed up execution times. To enable parallel execution of dependencies, set `runDependenciesConcurrently: true` in the command definition, right after specifying the dependencies.

For example:

```swift {4}
Command(
    description: "Build the project",
    dependencies: [clean, setupEnvironment, fetchDependencies],
    runDependenciesConcurrently: true
    run: { _ in
        print("Building the project...")
    }
)
```

In this example, the `clean`, `setupEnvironment`, and `fetchDependencies` commands will be executed concurrently, before running the `build` command.

::: warning
If dependencies write to stdout or stderr, logs may become mixed and hard to read when running them concurrently.
:::

### Direct Run

If using dependencies is not suitable for your needs, you can run another command directly using the `CommandRunner`.

For example:

```swift
public static var commandA: Command {
    Command(
        run: { context in
            try await CommandRunner(
                command: commandB,
                context: context
            )
            .run()
        }
    )
}

public static var commandB: Command { ...
```

In this example, `commandA` directly runs `commandB` using `CommandRunner`, passing along the current `context`. This allows for greater control over the execution flow without relying on predefined dependencies.e
