import Foundation
import SakeShared

func log(_ message: String) {
    var standardError = FileHandle.standardError
    print("[sake-app] \(message)", to: &standardError)
}

func logError(_ message: String) {
    log("Error: \(message)")
}

func logError(_ error: Error) {
    log("Error: \(error.localizedDescription)")
}
