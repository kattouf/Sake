import ArgumentParser
import CryptoKit
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

    public static var format: Command {
        Command(
            description: "Format code",
            run: { _ in
                try runAndPrint("swiftformat", "Sources", "SakeApp", "Tests", "Package.swift")
            }
        )
    }
}

@CommandGroup
struct TestCommands {
    public static var tests: Command {
        Command(
            description: "Run tests",
            dependencies: [unitTests, integrationTests]
        )
    }

    public static var unitTests: Command {
        Command(
            description: "Run unit tests",
            run: { _ in
                try runAndPrint("swift", "test", "--filter", "^(?!.*\\bIntegrationTests\\b).*", "--parallel")
            }
        )
    }

    public static var integrationTests: Command {
        Command(
            description: "Run integration tests",
            run: { _ in
                try runAndPrint("swift", "test", "--filter", "IntegrationTests", "--parallel")
            }
        )
    }
}

@CommandGroup
struct ReleaseCommands {
    private static let buildArtifactsDirectory = ".build/artifacts"

    struct ReleaseArguments: ParsableArguments {
        @Argument(help: "Version number")
        var version: String

        func validate() throws {
            guard version.range(of: #"^\d+\.\d+\.\d+$"#, options: .regularExpression) != nil else {
                throw ValidationError("Invalid version number. Should be in the format 'x.y.z'")
            }
        }
    }

    public static var release: Command {
        Command(
            description: "Release",
            dependencies: [buildReleaseArtifacts],
            run: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                try runAndPrint("sake", "createAndPushTag", arguments.version)
                try runAndPrint("sake", "draftReleaseWithArtifacts", arguments.version)
            }
        )
    }

    private static var buildReleaseArtifacts: Command {
        Command(
            description: "Build release artifacts",
            dependencies: [cleanReleaseArtifacts],
            run: { _ in
                var archivePaths = [String]()
                let triples = ["x86_64-apple-macosx", "arm64-apple-macosx"]
                let executableName = "sake"
                for triple in triples {
                    let buildFlags = ["--disable-sandbox", "--configuration", "release", "--triple", triple]
                    try runAndPrint("swift", "build", buildFlags)

                    let executablePath = run("swift", "build", buildFlags, "--show-bin-path").stdout + "/\(executableName)"
                    try runAndPrint("strip", "-rSTx", executablePath)

                    let executableArchivePath = "\(buildArtifactsDirectory)/\(executableName)-\(triple).zip"
                    try runAndPrint("zip", "-j", executableArchivePath, executablePath)
                    archivePaths.append(executableArchivePath)
                }

                var shasumResults = [String]()
                for archivePath in archivePaths {
                    let file = FileHandle(forReadingAtPath: archivePath)!
                    let shasum = SHA256.hash(data: file.readDataToEndOfFile())
                    let shasumString = shasum.compactMap { String(format: "%02x", $0) }.joined()
                    shasumResults.append("\(shasumString)  \(archivePath)")
                }
                FileManager.default.createFile(
                    atPath: ".build/artifacts/shasum",
                    contents: shasumResults.joined(separator: "\n").data(using: .utf8)
                )

                print("Release artifacts built successfully at '\(buildArtifactsDirectory)'")
            }
        )
    }

    private static var cleanReleaseArtifacts: Command {
        Command(
            description: "Clean release artifacts",
            run: { _ in
                try runAndPrint("rm", "-rf", buildArtifactsDirectory)
            }
        )
    }

    private static var createAndPushTag: Command {
        Command(
            description: "Create and push a tag",
            run: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                let version = arguments.version

                try runAndPrint("git", "tag", version)
                try runAndPrint("git", "push", "origin", "tag", version)
            }
        )
    }

    private static var draftReleaseWithArtifacts: Command {
        Command(
            description: "Draft a release on GitHub",
            run: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                let tagName = arguments.version
                let releaseTitle = arguments.version
                let draftReleaseCommand =
                    "gh release create \(tagName) \(buildArtifactsDirectory)/* --title '\(releaseTitle)' --draft --verify-tag --generate-notes"
                try runAndPrint(draftReleaseCommand)
            }
        )
    }
}
