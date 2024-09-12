import Foundation
import Sake
import SwiftShell

@main
@CommandGroup
struct Commands: SakeApp {
    public static var buildReleaseArtifacts: Command {
        Command(
            run: { _ in
                let triples = ["x86_64-apple-macosx", "arm64-apple-macosx"]
                let executableName = "sake"
                for triple in triples {
                    let buildFlags = ["--disable-sandbox", "--configuration", "release", "--triple", triple]
                    try runAndPrint("swift", "build", buildFlags)

                    let executablePath = run("swift", "build", buildFlags, "--show-bin-path").stdout + "/\(executableName)"
                    try runAndPrint("strip", "-rSTx", executablePath)

                    let executableArchivePath = ".build/artifacts/\(executableName)-\(triple).zip"
                    try runAndPrint("zip", "-j", executableArchivePath, executablePath)
                }
            }
        )
    }
}
