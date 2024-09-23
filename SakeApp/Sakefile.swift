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
    public static var buildReleaseArtifacts: Command {
        Command(
            description: "Build release artifacts",
            run: { _ in
                var archivePaths = [String]()
                let triples = ["x86_64-apple-macosx", "arm64-apple-macosx"]
                let executableName = "sake"
                for triple in triples {
                    let buildFlags = ["--disable-sandbox", "--configuration", "release", "--triple", triple]
                    try runAndPrint("swift", "build", buildFlags)

                    let executablePath = run("swift", "build", buildFlags, "--show-bin-path").stdout + "/\(executableName)"
                    try runAndPrint("strip", "-rSTx", executablePath)

                    let executableArchivePath = ".build/artifacts/\(executableName)-\(triple).zip"
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

                print("Release artifacts built successfully at '.build/artifacts/'")
            }
        )
    }
}
