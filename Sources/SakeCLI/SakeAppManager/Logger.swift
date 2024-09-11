import Foundation

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

extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        let data = Data(string.utf8)
        write(data)
    }
}
