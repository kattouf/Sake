import Foundation

extension Foundation.FileHandle: Swift.TextOutputStream {
    public func write(_ string: String) {
        let data = Data(string.utf8)
        write(data)
    }
}
