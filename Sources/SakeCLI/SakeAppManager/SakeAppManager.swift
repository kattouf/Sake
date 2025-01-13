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
    private static func makeDefault(sakeAppPath: String) -> Self {
        let fileHandle = DefaultSakeAppManagerFileHandle(path: sakeAppPath)
        let processMonitor = ProcessMonitor()
        processMonitor.monitor()
        let shellExecutor = ShellExecutor(processMonitor: processMonitor)
        let commandExecutor = DefaultSakeAppManagerCommandExecutor(fileHandle: fileHandle, shellExecutor: shellExecutor)
        return Self(fileHandle: fileHandle, commandExecutor: commandExecutor)
    }
}

// MARK: Uninitialized mode

extension SakeAppManager {
    static func makeInUninitializedMode(sakeAppPath: String) -> SakeAppManager<UninitializedMode> {
        .makeDefault(sakeAppPath: sakeAppPath)
    }
}

// MARK: Initialized mode

extension SakeAppManager {
    static func makeInInitializedMode(sakeAppPath: String) throws -> SakeAppManager<InitializedMode> {
        let sakeAppPath = try processSakeAppPath(sakeAppPath)
        return .makeDefault(sakeAppPath: sakeAppPath)
    }

    private static func processSakeAppPath(_ path: String) throws -> String {
        let standartizedPath = URL(fileURLWithPath: path).standardizedFileURL.path
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: standartizedPath, isDirectory: &isDirectory), isDirectory.boolValue {
            return standartizedPath
        } else if let nearestSakeApp = Self.findNearestProjectDirectory(from: standartizedPath) {
            log("SakeApp not found at \(standartizedPath). Using nearest SakeApp at \(nearestSakeApp).")
            return nearestSakeApp
        } else {
            throw SakeAppManagerError.sakeAppNotInitialized(path: path)
        }
    }

    private static func findNearestProjectDirectory(from path: String) -> String? {
        let defaultAppDirectoryName = "SakeApp"
        var currentPath = path
        while currentPath != "/" {
            let contents = try? FileManager.default.contentsOfDirectory(atPath: currentPath)
            if contents?.contains(defaultAppDirectoryName) == true {
                let sakeAppDirectoryCandidate = currentPath + "/" + defaultAppDirectoryName
                var isDirectory: ObjCBool = false
                guard FileManager.default.fileExists(atPath: sakeAppDirectoryCandidate, isDirectory: &isDirectory),
                      isDirectory.boolValue
                else {
                    continue
                }
                return sakeAppDirectoryCandidate
            }
            currentPath = URL(fileURLWithPath: currentPath).deletingLastPathComponent().path
        }
        return nil
    }
}
