import Foundation

func log(_ message: String) {
    var standardError = FileHandle.standardError
    print("[sake-cli] \(message)", to: &standardError)
}

func logError(_ message: String) {
    log("Error: \(message)")
}

func logError(_ error: Error) {
    log("Error: \(error.localizedDescription)")
}
