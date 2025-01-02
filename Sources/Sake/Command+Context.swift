import Foundation
import SakeShared

public extension Command {
    /// Represents the context in which a command is executed.
    ///
    /// The `Context` contains information such as command-line arguments,
    /// environment variables, and directories related to the app and its execution.
    struct Context: Sendable {
        /// The arguments passed to the command.
        ///
        /// This array contains the arguments that were provided when the command was executed.
        public let arguments: [String]

        /// The environment variables available during command execution.
        ///
        /// A dictionary of environment variables, where the key is the variable name,
        /// and the value is the variable's content.
        public let environment: [String: String]

        /// The directory where the application resides.
        ///
        /// This is typically the directory of the SakeApp where commands are managed.
        public let appDirectory: String

        /// The directory where the command is executed.
        ///
        /// This is the current working directory when the command runs.
        public let runDirectory: String

        /// A storage container for the context.
        ///
        /// This storage is used to share data between commands and store information
        public let storage: Storage

        /// A handler for process interruptions.
        ///
        /// This handler can be used to register cleanup tasks or other actions to be executed
        /// when the command (process) is interrupted.
        public let interruptionHandler: InterruptionHandler

        /// Initializes a new `Context` for command execution.
        ///
        /// - Parameters:
        ///   - arguments: The arguments passed to the command.
        ///   - environment: The environment variables available during execution.
        ///   - appDirectory: The directory where the app is located.
        ///   - runDirectory: The directory from which the command is run.
        ///   - storage: A storage container for the context.
        ///   - interruptionHandler: A handler for interruptions.
        init(
            arguments: [String],
            environment: [String: String],
            appDirectory: String,
            runDirectory: String,
            storage: Storage,
            interruptionHandler: InterruptionHandler
        ) {
            self.arguments = arguments
            self.environment = environment
            self.appDirectory = appDirectory
            self.runDirectory = runDirectory
            self.storage = storage
            self.interruptionHandler = interruptionHandler
        }
    }
}

#if canImport(SwiftShell)
    import SwiftShell
#endif

public extension Command.Context {
    /// Represents a handler for interruptions.
    ///
    /// The `InterruptionHandler` class provides a way to register cleanup tasks or other actions.
    final class InterruptionHandler: @unchecked Sendable {
        private let processMonitor: ProcessMonitor

        init(processMonitor: ProcessMonitor) {
            self.processMonitor = processMonitor
        }

        /// Registers a closure to be executed when the command is interrupted.
        public func register(_ handler: @escaping () -> Void) {
            processMonitor.runOnInterruption(handler)
        }

        #if canImport(SwiftShell)
            /// Registers a `SwiftShell` command to be interrupted sequentially when the command is interrupted.
            public func register(_ asyncCommand: PrintedAsyncCommand) {
                processMonitor.addProcess(asyncCommand)
            }
        #endif
    }

    /// Represents a storage container for the context.
    ///
    /// The `Storage` class provides a thread-safe storage container for the context.
    /// It allows for sharing data between commands and storing information during execution.
    final class Storage: @unchecked Sendable {
        private var dictionary: [String: Any] = [:]
        private let lock = NSRecursiveLock()

        init() {}

        public subscript(key: String) -> Any? {
            get { get(forKey: key) }
            set { set(newValue, forKey: key) }
        }

        public func set(_ value: Any?, forKey key: String) {
            lock.lock()
            defer { lock.unlock() }
            dictionary[key] = value
        }

        public func get(forKey key: String) -> Any? {
            lock.lock()
            defer { lock.unlock() }
            return dictionary[key]
        }

        public func remove(forKey key: String) {
            lock.lock()
            defer { lock.unlock() }
            dictionary.removeValue(forKey: key)
        }

        public func removeAll() {
            lock.lock()
            defer { lock.unlock() }
            dictionary.removeAll()
        }

        public func contains(key: String) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            return dictionary.keys.contains(key)
        }
    }
}
