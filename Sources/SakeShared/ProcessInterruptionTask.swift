import Foundation

/// The task to use in ProcessMonitor after process interruption.
package final class ProcessInterruptionTask {
    private let job: () -> Void
    private(set) var isCancelled = false
    private(set) var isDone = false

    package init(job: @escaping () -> Void) {
        self.job = job
    }

    /// Run only once per life
    package func run() {
        if Thread.isMainThread {
            body()
        } else {
            DispatchQueue.main.sync(execute: body)
        }
    }

    package func cancel() {
        isCancelled = true
    }

    private func body() {
        guard !isCancelled, !isDone else {
            return
        }
        job()
        isDone = true
    }
}
