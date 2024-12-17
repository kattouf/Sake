import SakeShared

struct CLIConfig {
    let configPath: String?
    let sakeAppPath: String?
    let sakeAppPrebuiltBinaryPath: String?
    let caseConvertingStrategy: CaseConvertingStrategy?

    init(commonOptions: CommonOptions, commandRelatedOptions: CommandRelatedCommonOptions?) {
        configPath = commonOptions.configPath
        sakeAppPath = commonOptions.sakeAppPath
        sakeAppPrebuiltBinaryPath = commandRelatedOptions?.sakeAppPrebuiltBinaryPath
        caseConvertingStrategy = commandRelatedOptions?.caseConvertingStrategy
    }

    private init(
        configPath: String?,
        sakeAppPath: String?,
        sakeAppPrebuiltBinaryPath: String?,
        caseConvertingStrategy: CaseConvertingStrategy?
    ) {
        self.configPath = configPath
        self.sakeAppPath = sakeAppPath
        self.sakeAppPrebuiltBinaryPath = sakeAppPrebuiltBinaryPath
        self.caseConvertingStrategy = caseConvertingStrategy
    }
}

extension CLIConfig {
    static func mock(
        configPath: String? = nil,
        sakeAppPath: String? = nil,
        sakeAppPrebuiltBinaryPath: String? = nil,
        caseConvertingStrategy: CaseConvertingStrategy? = nil
    ) -> CLIConfig {
        CLIConfig(
            configPath: configPath,
            sakeAppPath: sakeAppPath,
            sakeAppPrebuiltBinaryPath: sakeAppPrebuiltBinaryPath,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }
}
