import Foundation
#if canImport(SwiftShell)
    import SwiftShell
#endif

/// Synchronise shell subprocesses
public final class ProcessMonitor {
    #if canImport(SwiftShell)
        private let processes = NSHashTable<PrintedAsyncCommand>.weakObjects()
    #endif
    private lazy var signalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global(qos: .userInitiated))
    private var interruptionTasks: [ProcessInterruptionTask] = []
    private var isRunning = false

    public init() {}

    /// Catch SIGINT, clean up all subprocesses, and terminate root process manually
    public func monitor() {
        if isRunning {
            return /* Process monitor is already in progress */
        }
        isRunning = true

        // Make sure the signal does not terminate the application.
        signal(SIGINT, SIG_IGN)
        signalSource.setEventHandler { [weak self] in
            guard let self else {
                return
            }
            #if canImport(SwiftShell)
                self.processes.allObjects.forEach { $0.interrupt() }
            #endif
            self.interruptionTasks.forEach { $0.run() }
            exit(SIGINT)
        }
        signalSource.resume()
    }

    #if canImport(SwiftShell)
        /// Keep links to processes to interrupt them on SIGINT
        public func addProcess(_ process: PrintedAsyncCommand) {
            processes.add(process)
        }
    #endif

    /// Add a job to run after interruption
    @discardableResult
    public func runOnInterruption(_ job: @escaping () -> Void) -> ProcessInterruptionTask {
        let interruptionTask = ProcessInterruptionTask(job: job)
        interruptionTasks.append(interruptionTask)
        return interruptionTask
    }
}
