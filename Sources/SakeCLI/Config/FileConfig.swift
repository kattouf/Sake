import Foundation
import SakeShared
import Yams

struct FileConfig: Decodable {
    let sakeAppPath: String?
    let caseConvertingStrategy: CaseConvertingStrategy?

    enum CodingKeys: String, CodingKey {
        case sakeAppPath = "sake_app_path"
        case caseConvertingStrategy = "case_converting_strategy"
    }
}

extension FileConfig {
    static func mock(sakeAppPath: String? = nil, caseConvertingStrategy: CaseConvertingStrategy? = nil) -> FileConfig {
        FileConfig(sakeAppPath: sakeAppPath, caseConvertingStrategy: caseConvertingStrategy)
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
        return try YAMLDecoder().decode(FileConfig.self, from: data)
    }
}
