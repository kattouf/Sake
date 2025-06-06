import Foundation

package func log(_ message: String) {
    var standardError = FileHandle.standardError
    print("[sake-cli] \(message)", to: &standardError)
}

package func logError(_ message: String) {
    log("Error: \(message)")
}

package func logError(_ error: Error) {
    log("Error: \(error.localizedDescription)")
}
