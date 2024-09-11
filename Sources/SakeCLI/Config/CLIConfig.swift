import SakeShared

struct CLIConfig {
    let configPath: String?
    let sakeAppPath: String?
    let caseConvertingStrategy: CaseConvertingStrategy?

    init(commonOptions: CommonOptions, commandRelatedOptions: CommandRelatedCommonOptions?) {
        configPath = commonOptions.configPath
        sakeAppPath = commonOptions.sakeAppPath
        caseConvertingStrategy = commandRelatedOptions?.caseConvertingStrategy
    }

    private init(configPath: String?, sakeAppPath: String?, caseConvertingStrategy: CaseConvertingStrategy?) {
        self.configPath = configPath
        self.sakeAppPath = sakeAppPath
        self.caseConvertingStrategy = caseConvertingStrategy
    }
}

extension CLIConfig {
    static func mock(configPath: String? = nil, sakeAppPath: String? = nil, caseConvertingStrategy: CaseConvertingStrategy? = nil) -> CLIConfig {
        CLIConfig(configPath: configPath, sakeAppPath: sakeAppPath, caseConvertingStrategy: caseConvertingStrategy)
    }
}
