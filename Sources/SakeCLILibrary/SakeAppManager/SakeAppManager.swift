import Foundation
import SakeShared

// MARK: - SakeAppManager

package enum UninitializedMode {}
package enum InitializedMode {}

package struct SakeAppManager<Mode>: ~Copyable {
    let fileHandle: SakeAppManagerFileHandle
    let commandExecutor: SakeAppManagerCommandExecutor
}

// MARK: - Factory methods

extension SakeAppManager {
    package static func makeInUninitializedMode(sakeAppPath: String) -> SakeAppManager<UninitializedMode> {
        .makeDefault(sakeAppPath: sakeAppPath)
    }

    package static func makeInInitializedMode(sakeAppPath: String) throws -> SakeAppManager<InitializedMode> {
        try validateSakeAppIsExists(sakeAppPath: sakeAppPath)
        return .makeDefault(sakeAppPath: sakeAppPath)
    }

    private static func validateSakeAppIsExists(sakeAppPath: String) throws {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: sakeAppPath, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw SakeAppManagerError.sakeAppNotInitialized(path: sakeAppPath)
        }
    }

    private static func makeDefault(sakeAppPath: String) -> Self {
        let fileHandle = DefaultSakeAppManagerFileHandle(path: sakeAppPath)
        let shellExecutor = ShellExecutor()
        let commandExecutor = DefaultSakeAppManagerCommandExecutor(fileHandle: fileHandle, shellExecutor: shellExecutor)
        return Self(fileHandle: fileHandle, commandExecutor: commandExecutor)
    }
}
