import Foundation
import SakeShared

private var standardError = FileHandle.standardError

func log(_ message: String) {
    print("[sake-cli] \(message)", to: &standardError)
}

func logError(_ message: String) {
    log("Error: \(message)")
}

func logError(_ error: Error) {
    log("Error: \(error.localizedDescription)")
}
