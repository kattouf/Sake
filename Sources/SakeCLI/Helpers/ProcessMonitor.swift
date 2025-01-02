import Foundation
import SwiftShell

/// Synchronise shell subprocesses
final class ProcessMonitor {
    private let processes = NSHashTable<PrintedAsyncCommand>.weakObjects()
    private let signalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .global(qos: .userInitiated))
    private var interruptionTasks: [ProcessInterruptionTask] = []
    private var isRunning = false

    /// Catch SIGINT, clean up all subprocesses, and terminate root process manually
    func monitor() {
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
            print(" ✕ Interruption, please wait a bit. Cancelling \(self.processes.count) processes...")
            self.processes.allObjects.forEach { $0.interrupt() }
            self.interruptionTasks.forEach { $0.run() }
            exit(SIGINT)
        }
        signalSource.resume()
    }

    /// Keep links to processes to interrupt them on SIGINT
    func addProcess(_ process: PrintedAsyncCommand) {
        processes.add(process)
    }

    /// Add a job to run after interruption
    @discardableResult
    func runOnInterruption(_ job: @escaping () -> Void) -> ProcessInterruptionTask {
        let interruptionTask = ProcessInterruptionTask(job: job)
        interruptionTasks.append(interruptionTask)
        return interruptionTask
    }
}
