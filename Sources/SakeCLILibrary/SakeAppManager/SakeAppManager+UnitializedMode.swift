// MARK: - Unitialized mode

package extension SakeAppManager where Mode == UninitializedMode {
    @discardableResult
    consuming func initializeProject() async throws -> SakeAppManager<InitializedMode> {
        @discardableResult
        func initAndValidateInitializedManager() async throws -> SakeAppManager<InitializedMode> {
            let manager = SakeAppManager<InitializedMode>(
                fileHandle: fileHandle,
                commandExecutor: commandExecutor
            )
            try await manager.validateProject()
            return manager
        }

        let alreadyExists: Bool
        do {
            try await initAndValidateInitializedManager()
            alreadyExists = true
        } catch {
            alreadyExists = false
        }
        guard !alreadyExists else {
            throw SakeAppManagerError.sakeAppAlreadyInitialized(path: fileHandle.path)
        }

        log("Creating SakeApp package at path: \(fileHandle.path)...")
        try fileHandle.createProjectFiles()

        let initializedManager = try await initAndValidateInitializedManager()
        log("SakeApp package initialized successfully.")

        return initializedManager
    }
}
