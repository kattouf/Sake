@testable import SakeCLILibrary
import SakeShared
import XCTest

final class SakeAppManagerTests: XCTestCase {
    private let validPackageDump = """
    {
        "products" : [
            {
            "name" : "SakeApp",
            "type" : {
                "executable" : null
            }
            }
        ],
    }
    """

    // MARK: - Factory methods

    func testSakeAppManager_inInitializedMode_shouldNotInitialize_ifSakeAppDirectoryDoesNotExists() {
        do {
            _ = try SakeAppManager<InitializedMode>.makeInInitializedMode(sakeAppPath: "jepa")
            XCTFail("Expected error to be thrown")
        } catch {
            let sakeAppManagerError = error as! SakeAppManagerError
            if case .sakeAppNotInitialized = sakeAppManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected error: \(sakeAppManagerError)")
            }
        }
    }

    // MARK: - Initialize

    func testSakeAppManager_whenInitialize_shouldThrowError_IfAlreadyInitialized() async {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<UninitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        do {
            try await manager.initializeProject()
            XCTFail("Expected error to be thrown")
        } catch {
            let sakeAppManagerError = error as! SakeAppManagerError
            if case .sakeAppAlreadyInitialized = sakeAppManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected error: \(sakeAppManagerError)")
            }
        }
    }

    func testSakeAppManager_whenInitialize_shouldCreateFiles_andValidate() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { callCount in
                callCount == 0 ? "" : self.validPackageDump
            },
        )
        let manager = SakeAppManager<UninitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.initializeProject()

        XCTAssertEqual(fileHandle.createProjectFilesCallCount, 1)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 0)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 0)
        XCTAssertTrue(fileHandle.validatePackageSwiftExistsCallCount > 0)
    }

    // MARK: - Clean

    func testSakeAppManager_whenClean_shouldPackageClean() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.clean()

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 1)
    }

    // MARK: - Validate

    func testSakeAppManager_whenValidate_shouldValidatePackageSwiftExists_andPackageDump() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.validateProject()

        XCTAssertEqual(fileHandle.validatePackageSwiftExistsCallCount, 1)
        XCTAssertEqual(commandExecutor.packageDumpCallCount, 1)
    }

    func testSakeAppManager_whenValidate_shouldThrowError_IfPackageDumpIsInvalid() async {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in "jepa" },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        do {
            try await manager.validateProject()
            XCTFail("Expected error to be thrown")
        } catch {
            let sakeAppManagerError = error as! SakeAppManagerError
            if case .sakeAppNotValid(.failedToReadPackageSwift) = sakeAppManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected error: \(sakeAppManagerError)")
            }
        }
    }

    func testSakeAppManager_whenValidate_shouldThrowError_IfPackageDumpIsMissingSakeAppExecutable() async {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in """
            {
                "products" : [
                    {
                    "name" : "NotSakeApp",
                    "type" : {
                        "executable" : null
                    }
                    }
                ],
            }
            """
            },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        do {
            try await manager.validateProject()
            XCTFail("Expected error to be thrown")
        } catch {
            let sakeAppManagerError = error as! SakeAppManagerError
            if case .sakeAppNotValid(.failedToFindSakeAppExecutableInPackageProducts) = sakeAppManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected error: \(sakeAppManagerError)")
            }
        }
    }

    // MARK: - Build

    func testSakeAppManager_whenBuildSakeAppExecutableIfNeeded_shouldBuildExecutable_ifOutdated() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.buildExecutableIfNeeded()

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 0)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 1)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 1)
    }

    func testSakeAppManager_whenBuildSakeAppExecutableIfNeeded_shouldNotBuildExecutable_ifNotOutdated() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.buildExecutableIfNeeded()

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 0)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 0)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 0)
    }

    func testSakeAppManager_whenBuildSakeAppExecutableIfNeeded_shouldCleanPackageFirst_ifSwiftVersionWasChanged() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true,
            swiftVersionDumpReturnValue: "1.0.0",
        )
        let commandExecutor = MockCommandExecutor(
            swiftVersionDumpReturnValue: "1.0.1",
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.buildExecutableIfNeeded()

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 1)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 1)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 1)
    }

    func testSakeAppManager_whenBuildSakeAppExecutableIfNeeded_shouldNotCleanPackageFirst_ifLastSwiftVersionDumpMissed() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true,
            swiftVersionDumpReturnValue: nil,
        )
        let commandExecutor = MockCommandExecutor(
            swiftVersionDumpReturnValue: "1.0.1",
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.buildExecutableIfNeeded()

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 0)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 1)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 1)
    }

    func testSakeAppManager_whenBuildSakeAppExecutableIfNeeded_shouldTouchExecutable() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.buildExecutableIfNeeded()

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 0)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 1)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 1)
    }

    // MARK: - Run

    func testSakeAppManager_whenRunCommandOnExecutable_shouldCallRunCommand() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.run(
            prebuiltExecutablePath: nil,
            command: "command",
            args: ["arg1", "arg2"],
            caseConvertingStrategy: .keepOriginal,
        )

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 0)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 1)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 1)
        XCTAssertEqual(fileHandle.isPrebuiltExecutableExistsCallCount, 0)
        XCTAssertEqual(commandExecutor.callRunCommandOnExecutableCallCount, 1)
    }

    func testSakeAppManager_whenListAvailableCommands_shouldCallListCommand() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.listAvailableCommands(prebuiltExecutablePath: nil, caseConvertingStrategy: .keepOriginal, json: false)

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 0)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 1)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 1)
        XCTAssertEqual(fileHandle.isPrebuiltExecutableExistsCallCount, 0)
        XCTAssertEqual(commandExecutor.callListCommandOnExecutableCallCount, 1)
    }

    // MARK: Run prebuilt

    func testSakeAppManager_whenRunCommandOnPrebuiltExecutable_shouldCallRunCommand() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.run(
            prebuiltExecutablePath: "path",
            command: "command",
            args: ["arg1", "arg2"],
            caseConvertingStrategy: .keepOriginal,
        )

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 0)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 0)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 0)
        XCTAssertEqual(fileHandle.isPrebuiltExecutableExistsCallCount, 1)
        XCTAssertEqual(commandExecutor.callRunCommandOnExecutableCallCount, 1)
    }

    func testSakeAppManager_whenListAvailableCommandsOnPrebuiltExecutable_shouldCallListCommand() async throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true,
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump },
        )
        let manager = SakeAppManager<InitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try await manager.listAvailableCommands(prebuiltExecutablePath: "path", caseConvertingStrategy: .keepOriginal, json: false)

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 0)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 0)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 0)
        XCTAssertEqual(fileHandle.isPrebuiltExecutableExistsCallCount, 1)
        XCTAssertEqual(commandExecutor.callListCommandOnExecutableCallCount, 1)
    }
}

private final class MockFileHandle: SakeAppManagerFileHandle {
    let path: String
    let gitignorePath: String
    let packageSwiftPath: String
    let sakefilePath: String
    private(set) var createProjectFilesCallCount = 0
    private(set) var validatePackageSwiftExistsCallCount = 0
    private(set) var isExecutableOutdatedCallCount = 0
    private(set) var isExecutableOutdatedReturnValue: Bool
    private(set) var isPrebuiltExecutableExistsCallCount = 0
    private(set) var getSavedSwiftVersionDumpCallCount = 0
    private(set) var saveSwiftVersionDumpCallCount = 0
    let swiftVersionDumpReturnValue: String?

    init(
        path: String = "",
        gitignorePath: String = "",
        packageSwiftPath: String = "",
        sakefilePath: String = "",
        isExecutableOutdatedReturnValue: Bool,
        swiftVersionDumpReturnValue: String? = ""
    ) {
        self.path = path
        self.gitignorePath = gitignorePath
        self.packageSwiftPath = packageSwiftPath
        self.sakefilePath = sakefilePath
        self.isExecutableOutdatedReturnValue = isExecutableOutdatedReturnValue
        self.swiftVersionDumpReturnValue = swiftVersionDumpReturnValue
    }

    func createProjectFiles() throws {
        createProjectFilesCallCount += 1
    }

    func validatePackageSwiftExists() throws {
        validatePackageSwiftExistsCallCount += 1
    }

    func isExecutableOlderThenSourceFiles(executablePath _: String) throws -> Bool {
        isExecutableOutdatedCallCount += 1
        return isExecutableOutdatedReturnValue
    }

    func isPrebuiltExecutableExists(path _: String) -> Bool {
        isPrebuiltExecutableExistsCallCount += 1
        return true
    }

    func getSavedSwiftVersionDump(binPath _: String) throws -> String? {
        getSavedSwiftVersionDumpCallCount += 1
        return swiftVersionDumpReturnValue
    }

    func saveSwiftVersionDump(binPath _: String, dump _: String) throws {
        saveSwiftVersionDumpCallCount += 1
    }
}

private final class MockCommandExecutor: SakeAppManagerCommandExecutor {
    private(set) var swiftVersionDumpCallCount = 0
    private(set) var packageDumpCallCount = 0
    private(set) var packageCleanCallCount = 0
    private(set) var packageShowBinPathCallCount = 0
    private(set) var buildExecutableCallCount = 0
    private(set) var touchExecutableCallCount = 0
    private(set) var callListCommandOnExecutableCallCount = 0
    private(set) var callRunCommandOnExecutableCallCount = 0

    let swiftVersionDumpReturnValue: String
    let packageDumpReturnValue: (_ callNumber: Int) -> String
    let packageShowBinPathReturnValue: String

    init(
        swiftVersionDumpReturnValue: String = "",
        packageDumpReturnValue: @escaping (_ callNumber: Int) -> String,
        packageShowBinPathReturnValue: String = ""
    ) {
        self.swiftVersionDumpReturnValue = swiftVersionDumpReturnValue
        self.packageDumpReturnValue = packageDumpReturnValue
        self.packageShowBinPathReturnValue = packageShowBinPathReturnValue
    }

    func swiftVersionDump() async throws -> String {
        swiftVersionDumpCallCount += 1
        return swiftVersionDumpReturnValue
    }

    func packageDump() async throws -> String {
        let currentCallCount = packageDumpCallCount
        packageDumpCallCount += 1
        return packageDumpReturnValue(currentCallCount)
    }

    func packageClean() async throws {
        packageCleanCallCount += 1
    }

    func packageShowBinPath() async throws -> String {
        packageShowBinPathCallCount += 1
        return ""
    }

    func buildExecutable() async throws {
        buildExecutableCallCount += 1
    }

    func touchExecutable(executablePath _: String) async {
        touchExecutableCallCount += 1
    }

    func callListCommandOnExecutable(
        executablePath _: String,
        json _: Bool,
        caseConvertingStrategy _: CaseConvertingStrategy,
    ) async throws {
        callListCommandOnExecutableCallCount += 1
    }

    func callRunCommandOnExecutable(
        executablePath _: String,
        command _: String,
        args _: [String],
        caseConvertingStrategy _: CaseConvertingStrategy,
    ) async throws {
        callRunCommandOnExecutableCallCount += 1
    }
}
