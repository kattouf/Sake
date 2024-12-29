import ArgumentParser
import Crypto
import Foundation
import Sake
import SwiftShell

@CommandGroup
struct ReleaseCommands {
    private struct BuildTarget {
        enum Arch {
            case x86
            case arm
        }

        enum OS {
            case macos
            case linux
        }

        let arch: Arch
        let os: OS

        var triple: String {
            switch (arch, os) {
            case (.x86, .macos): "x86_64-apple-macosx"
            case (.arm, .macos): "arm64-apple-macosx"
            case (.x86, .linux): "x86_64-unknown-linux-gnu"
            case (.arm, .linux): "aarch64-unknown-linux-gnu"
            }
        }
    }

    private enum Constants {
        static let swiftVersion = "6.0"
        static let buildArtifactsDirectory = ".build/artifacts"
        static let buildTargets: [BuildTarget] = [
            .init(arch: .arm, os: .macos),
            .init(arch: .x86, os: .macos),
            .init(arch: .x86, os: .linux),
            .init(arch: .arm, os: .linux),
        ]
        static let executableOriginalName = "SakeCLI"
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
            dependencies: [
                bumpVersion,
                cleanReleaseArtifacts,
                buildReleaseArtifacts,
                calculateBuildArtifactsSha256,
                createAndPushTag,
                generateReleaseNotes,
                draftReleaseWithArtifacts,
            ]
        )
    }

    static var bumpVersion: Command {
        Command(
            description: "Bump version",
            skipIf: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                let version = arguments.version
                let versionFilePath = "Sources/SakeCLI/Version.swift"
                let currentVersion = try String(contentsOfFile: versionFilePath)
                    .split(separator: "\"")[1]
                if currentVersion == version {
                    print("Version is already \(version). Skipping...")
                    return true
                } else {
                    return false
                }
            },
            run: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                let version = arguments.version
                let versionFilePath = "Sources/SakeCLI/Version.swift"
                let versionFileContent = """
                // This file is autogenerated. Do not edit.
                let sakeCLIVersion = "\(version)"

                """
                try versionFileContent.write(toFile: versionFilePath, atomically: true, encoding: .utf8)

                try runAndPrint("git", "add", versionFilePath)
                try runAndPrint("git", "commit", "-m", "chore(release): Bump version to \(version)")
                print("Version bumped to \(version)")
            }
        )
    }

    static var buildReleaseArtifacts: Command {
        Command(
            description: "Build release artifacts",
            skipIf: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()
                let version = arguments.version

                let targetsWithExistingArtifacts = Constants.buildTargets.filter { target in
                    let archivePath = executableArchivePath(target: target, version: version)
                    return FileManager.default.fileExists(atPath: archivePath)
                }
                if targetsWithExistingArtifacts.count == Constants.buildTargets.count {
                    print("Release artifacts already exist. Skipping...")
                    return true
                } else {
                    context.storage["existing-artifacts-triples"] = targetsWithExistingArtifacts.map(\.triple)
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
                let existingArtifactsTriples = context.storage["existing-artifacts-triples"] as? [String] ?? []
                for target in Constants.buildTargets {
                    if existingArtifactsTriples.contains(target.triple) {
                        print("Skipping \(target.triple) as artifacts already exist")
                        continue
                    }
                    let (swiftBuild, swiftClean, strip, zip) = {
                        let buildFlags = ["--disable-sandbox", "--configuration", "release", "--triple", target.triple]
                            .joined(separator: " ")
                        if target.os == .linux {
                            let platform = target.arch == .arm ? "linux/arm64" : "linux/amd64"
                            let dockerExec =
                                "docker run --rm --volume \(context.projectRoot):/workdir --workdir /workdir --platform \(platform) swift:\(Constants.swiftVersion)"
                            return (
                                "\(dockerExec) swift build --static-swift-stdlib \(buildFlags)",
                                "\(dockerExec) swift package clean",
                                "\(dockerExec) strip -s",
                                "zip -j"
                            )
                        } else {
                            return (
                                "swift build \(buildFlags)",
                                "swift package clean",
                                "strip -rSTx",
                                "zip -j"
                            )
                        }
                    }()

                    try runAndPrint(bash: swiftClean)
                    try runAndPrint(bash: swiftBuild)

                    let binPath: String = run(bash: "\(swiftBuild) --show-bin-path").stdout
                    if binPath.isEmpty {
                        throw NSError(domain: "Fail to get bin path", code: -999)
                    }
                    let executablePath = binPath + "/\(Constants.executableName)"

                    try runAndPrint(bash: "\(strip) \(executablePath)")

                    let executableArchivePath = executableArchivePath(target: target, version: version)
                    try runAndPrint(
                        bash: "\(zip) \(executableArchivePath) \(executablePath.replacingOccurrences(of: "/workdir", with: context.projectRoot))"
                    )
                }

                print("Release artifacts built successfully at '\(Constants.buildArtifactsDirectory)'")
            }
        )
    }

    static var calculateBuildArtifactsSha256: Command {
        @Sendable
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
                for target in Constants.buildTargets {
                    let archivePath = executableArchivePath(target: target, version: version)
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
                try runAndPrint("git", "push") // push local changes like version bump
            }
        )
    }

    static var generateReleaseNotes: Command {
        Command(
            description: "Generate release notes",
            dependencies: [MiseCommands.ensureGitCliffInstalled],
            skipIf: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                let version = arguments.version
                let releaseNotesPath = releaseNotesPath(version: version)
                if FileManager.default.fileExists(atPath: releaseNotesPath) {
                    print("Release notes for \(version) already exist at \(releaseNotesPath). Skipping...")
                    return true
                } else {
                    return false
                }
            },
            run: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                let version = arguments.version
                let releaseNotesPath = releaseNotesPath(version: version)
                try runAndPrint(
                    "mise",
                    "exec",
                    "--",
                    "git",
                    "cliff",
                    "--latest",
                    "--strip=all",
                    "--tag",
                    version,
                    "--output",
                    releaseNotesPath
                )
                print("Release notes generated at \(releaseNotesPath)")
            }
        )
    }

    static var draftReleaseWithArtifacts: Command {
        Command(
            description: "Draft a release on GitHub",
            dependencies: [MiseCommands.ensureGhInstalled],
            skipIf: { context in
                let arguments = try ReleaseArguments.parse(context.arguments)
                try arguments.validate()

                let tagName = arguments.version
                let ghViewResult = run(bash: "mise exec -- gh release view \(tagName)")
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
                    "mise exec -- gh release create \(tagName) \(Constants.buildArtifactsDirectory)/*.zip --title '\(releaseTitle)' --draft --verify-tag --notes-file \(releaseNotesPath(version: tagName))"
                try runAndPrint(bash: draftReleaseCommand)
            }
        )
    }
}

// MARK: - Helpers

extension ReleaseCommands {
    private static func executableArchivePath(target: BuildTarget, version: String) -> String {
        "\(Constants.buildArtifactsDirectory)/\(Constants.executableName)-\(version)-\(target.triple).zip"
    }

    private static func releaseNotesPath(version: String) -> String {
        ".build/artifacts/release-notes-\(version).md"
    }
}
