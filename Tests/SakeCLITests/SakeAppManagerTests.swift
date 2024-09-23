@testable import SakeCLI
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

    func testSakeAppManager_whenInitialize_shouldThrowError_IfAlreadyInitialized() throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump }
        )
        let manager = SakeAppManager(fileHandle: fileHandle, commandExecutor: commandExecutor)

        XCTAssertThrowsError(try manager.initialize()) { error in
            let sakeAppManagerError = error as! SakeAppManager.Error
            if case .sakeAppAlreadyInitialized = sakeAppManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected error: \(sakeAppManagerError)")
            }
        }
    }

    func testSakeAppManager_whenInitialize_shouldCreateFiles_buildExecutable_andValidate() throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { callCount in
                callCount == 0 ? "" : self.validPackageDump
            }
        )
        let manager = SakeAppManager(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try manager.initialize()

        XCTAssertEqual(fileHandle.createProjectFilesCallCount, 1)
        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 1)
        XCTAssertEqual(commandExecutor.touchExecutableCallCount, 1)
        XCTAssertTrue(fileHandle.validatePackageSwiftExistsCallCount > 0)
    }

    func testSakeAppManager_whenClean_shouldPackageClean() throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump }
        )
        let manager = SakeAppManager(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try manager.clean()

        XCTAssertEqual(commandExecutor.packageCleanCallCount, 1)
    }

    func testSakeAppManager_whenValidate_shouldValidatePackageSwiftExists_andPackageDump() throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump }
        )
        let manager = SakeAppManager(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try manager.validate()

        XCTAssertEqual(fileHandle.validatePackageSwiftExistsCallCount, 1)
        XCTAssertEqual(commandExecutor.packageDumpCallCount, 1)
    }

    func testSakeAppManager_whenValidate_shouldThrowError_IfPackageDumpIsInvalid() throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in "jepa" }
        )
        let manager = SakeAppManager(fileHandle: fileHandle, commandExecutor: commandExecutor)

        XCTAssertThrowsError(try manager.validate()) { error in
            let sakeAppManagerError = error as! SakeAppManager.Error
            if case .sakeAppNotValid(.failedToReadPackageSwift) = sakeAppManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected error: \(sakeAppManagerError)")
            }
        }
    }

    func testSakeAppManager_whenValidate_shouldThrowError_IfPackageDumpIsMissingSakeAppExecutable() throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false
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
            }
        )
        let manager = SakeAppManager(fileHandle: fileHandle, commandExecutor: commandExecutor)

        XCTAssertThrowsError(try manager.validate()) { error in
            let sakeAppManagerError = error as! SakeAppManager.Error
            if case .sakeAppNotValid(.failedToFindSakeAppExecutableInPackageProducts) = sakeAppManagerError {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected error: \(sakeAppManagerError)")
            }
        }
    }

    func testSakeAppManager_whenRunCommandOnExecutable_shouldBuildExecutable_ifOutdated_andCallRunCommand() throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump }
        )
        let manager = SakeAppManager(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try manager.run(command: "command", args: ["arg1", "arg2"], caseConvertingStrategy: .keepOriginal)

        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 1)
        XCTAssertEqual(commandExecutor.callRunCommandOnExecutableCallCount, 1)
    }

    func testSakeAppManager_whenRunCommandOnExecutable_shouldNotBuildExecutable_ifNotOutdated_andCallRunCommand() throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump }
        )
        let manager = SakeAppManager(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try manager.run(command: "command", args: ["arg1", "arg2"], caseConvertingStrategy: .keepOriginal)

        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 0)
        XCTAssertEqual(commandExecutor.callRunCommandOnExecutableCallCount, 1)
    }

    func testSakeAppManager_whenListAvailableCommands_shouldBuildExecutable_andCallListCommand() throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: true
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump }
        )
        let manager = SakeAppManager(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try manager.listAvailableCommands(caseConvertingStrategy: .keepOriginal, json: false)

        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 1)
        XCTAssertEqual(commandExecutor.callListCommandOnExecutableCallCount, 1)
    }

    func testSakeAppManager_whenListAvailableCommands_shouldNotBuildExecutable_ifNotOutdated_andCallListCommand() throws {
        let fileHandle = MockFileHandle(
            isExecutableOutdatedReturnValue: false
        )
        let commandExecutor = MockCommandExecutor(
            packageDumpReturnValue: { _ in self.validPackageDump }
        )
        let manager = SakeAppManager(fileHandle: fileHandle, commandExecutor: commandExecutor)

        try manager.listAvailableCommands(caseConvertingStrategy: .keepOriginal, json: false)

        XCTAssertEqual(commandExecutor.buildExecutableCallCount, 0)
        XCTAssertEqual(commandExecutor.callListCommandOnExecutableCallCount, 1)
    }
}

private final class MockFileHandle: SakeAppManager.FileHandle {
    let path: String
    let gitignorePath: String
    let packageSwiftPath: String
    let sakefilePath: String
    private(set) var createProjectFilesCallCount = 0
    private(set) var validatePackageSwiftExistsCallCount = 0
    private(set) var isExecutableOutdatedCallCount = 0
    private(set) var isExecutableOutdatedReturnValue: Bool

    init(
        path: String = "",
        gitignorePath: String = "",
        packageSwiftPath: String = "",
        sakefilePath: String = "",
        isExecutableOutdatedReturnValue: Bool
    ) {
        self.path = path
        self.gitignorePath = gitignorePath
        self.packageSwiftPath = packageSwiftPath
        self.sakefilePath = sakefilePath
        self.isExecutableOutdatedReturnValue = isExecutableOutdatedReturnValue
    }

    func createProjectFiles() throws {
        createProjectFilesCallCount += 1
    }

    func validatePackageSwiftExists() throws {
        validatePackageSwiftExistsCallCount += 1
    }

    func isExecutableOutdated(executablePath _: String) throws -> Bool {
        isExecutableOutdatedCallCount += 1
        return isExecutableOutdatedReturnValue
    }
}

private final class MockCommandExecutor: SakeAppManager.CommandExecutor {
    private(set) var packageDumpCallCount = 0
    private(set) var packageCleanCallCount = 0
    private(set) var packageShowBinPathCallCount = 0
    private(set) var buildExecutableCallCount = 0
    private(set) var touchExecutableCallCount = 0
    private(set) var callListCommandOnExecutableCallCount = 0
    private(set) var callRunCommandOnExecutableCallCount = 0

    let packageDumpReturnValue: (_ callNumber: Int) -> String
    let packageShowBinPathReturnValue: String

    init(
        packageDumpReturnValue: @escaping (_ callNumber: Int) -> String,
        packageShowBinPathReturnValue: String = ""
    ) {
        self.packageDumpReturnValue = packageDumpReturnValue
        self.packageShowBinPathReturnValue = packageShowBinPathReturnValue
    }

    func packageDump() throws -> String {
        let currentCallCount = packageDumpCallCount
        packageDumpCallCount += 1
        return packageDumpReturnValue(currentCallCount)
    }

    func packageClean() throws {
        packageCleanCallCount += 1
    }

    func packageShowBinPath() throws -> String {
        packageShowBinPathCallCount += 1
        return ""
    }

    func buildExecutable() throws {
        buildExecutableCallCount += 1
    }

    func touchExecutable(executablePath _: String) {
        touchExecutableCallCount += 1
    }

    func callListCommandOnExecutable(executablePath _: String, json _: Bool, caseConvertingStrategy _: CaseConvertingStrategy) throws {
        callListCommandOnExecutableCallCount += 1
    }

    func callRunCommandOnExecutable(
        executablePath _: String,
        command _: String,
        args _: [String],
        caseConvertingStrategy _: CaseConvertingStrategy
    ) throws {
        callRunCommandOnExecutableCallCount += 1
    }
}
