import Foundation

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

        /// Initializes a new `Context` for command execution.
        ///
        /// - Parameters:
        ///   - arguments: The arguments passed to the command.
        ///   - environment: The environment variables available during execution.
        ///   - appDirectory: The directory where the app is located.
        ///   - runDirectory: The directory from which the command is run.
        ///   - storage: A storage container for the context.
        public init(
            arguments: [String],
            environment: [String: String],
            appDirectory: String,
            runDirectory: String,
            storage: Storage
        ) {
            self.arguments = arguments
            self.environment = environment
            self.appDirectory = appDirectory
            self.runDirectory = runDirectory
            self.storage = storage
        }
    }
}

public extension Command.Context {
    /// Represents a storage container for the context.
    ///
    /// The `Storage` class provides a thread-safe storage container for the context.
    /// It allows for sharing data between commands and storing information during execution.
    final class Storage: @unchecked Sendable {
        private var dictionary: [String: Any] = [:]
        private let lock = NSRecursiveLock()

        public init() {}

        subscript(key: String) -> Any? {
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
