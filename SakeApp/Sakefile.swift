import ArgumentParser
import Foundation
import Sake
import SwiftShell

@main
@CommandGroup
struct Commands: SakeApp {
    public static var configuration: SakeAppConfiguration {
        SakeAppConfiguration(
            commandGroups: [
                TestCommands.self,
                ReleaseCommands.self,
            ]
        )
    }

    public static var lint: Command {
        Command(
            description: "Lint code",
            dependencies: [MiseCommands.ensureSwiftFormatInstalled],
            run: { context in
                try runAndPrint(
                    "mise",
                    "exec",
                    "--",
                    "swiftformat",
                    "\(context.projectRoot)/Sources",
                    "\(context.projectRoot)/SakeApp",
                    "\(context.projectRoot)/Tests",
                    "\(context.projectRoot)/Package.swift",
                    "--lint"
                )
            }
        )
    }

    public static var format: Command {
        Command(
            description: "Format code",
            dependencies: [MiseCommands.ensureSwiftFormatInstalled],
            run: { context in
                try runAndPrint(
                    "mise",
                    "exec",
                    "--",
                    "swiftformat",
                    "\(context.projectRoot)/Sources",
                    "\(context.projectRoot)/SakeApp",
                    "\(context.projectRoot)/Tests",
                    "\(context.projectRoot)/Package.swift"
                )
            }
        )
    }
}

extension Command.Context {
    var projectRoot: String {
        "\(appDirectory)/.."
    }
}
