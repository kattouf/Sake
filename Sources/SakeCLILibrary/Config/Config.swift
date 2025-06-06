import Foundation
import SakeShared

package struct Config {
    package let configPath: String
    package let sakeAppPath: String
    package let sakeAppPrebuiltBinaryPath: String?
    package let caseConvertingStrategy: CaseConvertingStrategy
}

extension Config {
    static let `default` = Config(
        configPath: FileManager.default.currentDirectoryPath + "/.sake.yml",
        sakeAppPath: FileManager.default.currentDirectoryPath + "/SakeApp",
        sakeAppPrebuiltBinaryPath: nil,
        caseConvertingStrategy: CaseConvertingStrategy.keepOriginal,
    )
}
