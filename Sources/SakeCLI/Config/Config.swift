import ArgumentParser
import Foundation
import SakeShared

struct Config {
    let configPath: String
    let sakeAppPath: String
    let sakeAppPrebuiltBinaryPath: String?
    let caseConvertingStrategy: CaseConvertingStrategy
}

extension Config {
    static let `default` = Config(
        configPath: FileManager.default.currentDirectoryPath + "/.sake.yml",
        sakeAppPath: FileManager.default.currentDirectoryPath + "/SakeApp",
        sakeAppPrebuiltBinaryPath: nil,
        caseConvertingStrategy: CaseConvertingStrategy.keepOriginal,
    )
}
