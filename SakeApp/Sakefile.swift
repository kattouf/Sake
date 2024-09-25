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
    private enum Constants {
        static let buildArtifactsDirectory = ".build/artifacts"
        static let triples = ["x86_64-apple-macosx", "arm64-apple-macosx"]
        static let executableName = "sake"
    }

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
            dependencies: [buildReleaseArtifacts, calculateBuildArtifactsSha256, createAndPushTag, draftReleaseWithArtifacts]
        )
    }

    static var buildReleaseArtifacts: Command {
        Command(
            description: "Build release artifacts",
            dependencies: [cleanReleaseArtifacts],
            skipIf: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()
                let version = arguments.version

                let areAllArtifactsExists = Constants.triples.allSatisfy { triple in
                    let archivePath = executableArchivePath(triple: triple, version: version)
                    return FileManager.default.fileExists(atPath: archivePath)
                }
                if areAllArtifactsExists {
                    print("Release artifacts already exist. Skipping...")
                    return true
                } else {
                    return false
                }
            },
            run: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()
                let version = arguments.version

                try FileManager.default.createDirectory(
                    atPath: Constants.buildArtifactsDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )

                for triple in Constants.triples {
                    try runAndPrint("swift", "package", "clean")

                    let buildFlags = ["--disable-sandbox", "--configuration", "release", "--triple", triple]
                    try runAndPrint("swift", "build", buildFlags, "--jobs", "10")

                    let executablePath = run("swift", "build", buildFlags, "--show-bin-path").stdout + "/\(Constants.executableName)"
                    try runAndPrint("strip", "-rSTx", executablePath)

                    let executableArchivePath = executableArchivePath(triple: triple, version: version)
                    try runAndPrint("zip", "-j", executableArchivePath, executablePath)
                }

                print("Release artifacts built successfully at '\(Constants.buildArtifactsDirectory)'")
            }
        )
    }

    static var calculateBuildArtifactsSha256: Command {
        func shasumFilePath(version: String) -> String {
            ".build/artifacts/shasum-\(version)"
        }

        return Command(
            description: "Calculate SHA-256 checksums for build artifacts",
            skipIf: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()
                let version = arguments.version

                let shasumFilePath = shasumFilePath(version: version)

                return FileManager.default.fileExists(atPath: shasumFilePath)
            },
            run: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()
                let version = arguments.version

                var shasumResults = [String]()
                for triple in Constants.triples {
                    let archivePath = executableArchivePath(triple: triple, version: version)
                    let file = FileHandle(forReadingAtPath: archivePath)!
                    let shasum = SHA256.hash(data: file.readDataToEndOfFile())
                    let shasumString = shasum.compactMap { String(format: "%02x", $0) }.joined()
                    shasumResults.append("\(shasumString)  \(archivePath)")
                }
                FileManager.default.createFile(
                    atPath: shasumFilePath(version: version),
                    contents: shasumResults.joined(separator: "\n").data(using: .utf8)
                )
            }
        )
    }

    private static func executableArchivePath(triple: String, version: String) -> String {
        "\(Constants.buildArtifactsDirectory)/\(Constants.executableName)-\(version)-\(triple).zip"
    }

    static var cleanReleaseArtifacts: Command {
        Command(
            description: "Clean release artifacts",
            run: { _ in
                try? runAndPrint("rm", "-rf", Constants.buildArtifactsDirectory)
            }
        )
    }

    static var createAndPushTag: Command {
        Command(
            description: "Create and push a tag",
            skipIf: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                let version = arguments.version

                let grepResult = run(bash: "git tag | grep \(arguments.version)")
                if grepResult.succeeded {
                    print("Tag \(version) already exists. Skipping...")
                    return true
                } else {
                    return false
                }
            },
            run: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                let version = arguments.version

                print("Creating and pushing tag \(version)")
                try runAndPrint("git", "tag", version)
                try runAndPrint("git", "push", "origin", "tag", version)
            }
        )
    }

    static var draftReleaseWithArtifacts: Command {
        Command(
            description: "Draft a release on GitHub",
            skipIf: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                let tagName = arguments.version
                let ghViewResult = run(bash: "gh release view \(tagName)")
                if ghViewResult.succeeded {
                    print("Release \(tagName) already exists. Skipping...")
                    return true
                } else {
                    return false
                }
            },
            run: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                print("Drafting release \(arguments.version) on GitHub")
                let tagName = arguments.version
                let releaseTitle = arguments.version
                let draftReleaseCommand =
                    "gh release create \(tagName) \(Constants.buildArtifactsDirectory)/*.zip --title '\(releaseTitle)' --draft --verify-tag --generate-notes"
                try runAndPrint(bash: draftReleaseCommand)
            }
        )
    }
}
