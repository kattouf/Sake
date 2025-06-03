import Foundation
import SakeShared

// MARK: - SakeAppManager

enum UninitializedMode {}
enum InitializedMode {}

#if swift(>=6.0)
    struct SakeAppManager<Mode>: ~Copyable {
        let fileHandle: SakeAppManagerFileHandle
        let commandExecutor: SakeAppManagerCommandExecutor
    }
#else
    struct SakeAppManager<Mode> {
        let fileHandle: SakeAppManagerFileHandle
        let commandExecutor: SakeAppManagerCommandExecutor
    }
#endif

// MARK: - Factory methods

extension SakeAppManager {
    static func makeInUninitializedMode(sakeAppPath: String) -> SakeAppManager<UninitializedMode> {
        .makeDefault(sakeAppPath: sakeAppPath)
    }

    static func makeInInitializedMode(sakeAppPath: String) throws -> SakeAppManager<InitializedMode> {
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
