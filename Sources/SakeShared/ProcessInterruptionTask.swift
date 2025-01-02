import Foundation

/// The task to use in ProcessMonitor after process interruption.
public final class ProcessInterruptionTask {
    private let job: () -> Void
    private(set) var isCancelled = false
    private(set) var isDone = false

    public init(job: @escaping () -> Void) {
        self.job = job
    }

    /// Run only once per life
    public func run() {
        if Thread.isMainThread {
            body()
        } else {
            DispatchQueue.main.sync(execute: body)
        }
    }

    public func cancel() {
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
