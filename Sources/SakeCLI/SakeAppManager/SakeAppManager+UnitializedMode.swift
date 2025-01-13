// MARK: - Unitialized mode

extension SakeAppManager where Mode == UninitializedMode {
    @discardableResult
    consuming func initializeProject() throws -> SakeAppManager<InitializedMode> {
        @discardableResult
        func initAndValidateInitializedManager() throws -> SakeAppManager<InitializedMode> {
            let manager = SakeAppManager<InitializedMode>(
                fileHandle: fileHandle,
                commandExecutor: commandExecutor
            )
            try manager.validateProject()
            return manager
        }

        let alreadyExists: Bool
        do {
            try initAndValidateInitializedManager()
            alreadyExists = true
        } catch {
            alreadyExists = false
        }
        guard !alreadyExists else {
            throw SakeAppManagerError.sakeAppAlreadyInitialized(path: fileHandle.path)
        }

        log("Creating SakeApp package at path: \(fileHandle.path)...")
        try fileHandle.createProjectFiles()

        let initializedManager = try initAndValidateInitializedManager()
        log("SakeApp package initialized successfully.")

        return initializedManager
    }
}
