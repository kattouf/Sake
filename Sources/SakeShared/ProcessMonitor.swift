import Foundation
#if canImport(SwiftShell)
    import SwiftShell
#endif

/// Synchronise shell subprocesses
package final class ProcessMonitor {
    #if canImport(SwiftShell)
        private final class WeakBox<T: AnyObject> {
            weak var value: T?

            init(_ value: T) {
                self.value = value
            }
        }

        private var processes = [WeakBox<PrintedAsyncCommand>]()
    #endif
    private lazy var signalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global(qos: .userInitiated))
    private var interruptionTasks: [ProcessInterruptionTask] = []
    private var isRunning = false

    package init() {}

    /// Catch SIGINT, clean up all subprocesses, and terminate root process manually
    package func monitor() {
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
                self.processes.forEach { $0.value?.interrupt() }
            #endif
            self.interruptionTasks.forEach { $0.run() }
            exit(SIGINT)
        }
        signalSource.resume()
    }

    #if canImport(SwiftShell)
        /// Keep links to processes to interrupt them on SIGINT
        package func addProcess(_ process: PrintedAsyncCommand) {
            processes.append(.init(process))
        }
    #endif

    /// Add a job to run after interruption
    @discardableResult
    package func runOnInterruption(_ job: @escaping () -> Void) -> ProcessInterruptionTask {
        let interruptionTask = ProcessInterruptionTask(job: job)
        interruptionTasks.append(interruptionTask)
        return interruptionTask
    }
}
