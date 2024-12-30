import Foundation
import SakeShared
import Yams

struct FileConfig: Decodable {
    let sakeAppPath: String?
    let sakeAppPrebuiltBinaryPath: String?
    let caseConvertingStrategy: CaseConvertingStrategy?

    enum CodingKeys: String, CodingKey {
        case sakeAppPath = "sake_app_path"
        case sakeAppPrebuiltBinaryPath = "sake_app_prebuilt_binary_path"
        case caseConvertingStrategy = "case_converting_strategy"
    }
}

extension FileConfig {
    static func mock(
        sakeAppPath: String? = nil,
        sakeAppPrebuiltBinaryPath: String? = nil,
        caseConvertingStrategy: CaseConvertingStrategy? = nil
    ) -> FileConfig {
        FileConfig(
            sakeAppPath: sakeAppPath,
            sakeAppPrebuiltBinaryPath: sakeAppPrebuiltBinaryPath,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }
}

final class FileConfigManager {
    private let configPath: String

    init?(configPath: String) {
        guard FileManager.default.fileExists(atPath: configPath) else {
            return nil
        }
        self.configPath = configPath
    }

    func load() throws -> FileConfig {
        let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
        let decoded = try YAMLDecoder().decode(FileConfig.self, from: data)
        return FileConfig(
            sakeAppPath: decoded.sakeAppPath?.nilIfEmpty(),
            sakeAppPrebuiltBinaryPath: decoded.sakeAppPrebuiltBinaryPath?.nilIfEmpty(),
            caseConvertingStrategy: decoded.caseConvertingStrategy
        )
    }
}
