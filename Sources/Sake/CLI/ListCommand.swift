import ArgumentParser

struct ListCommand: SakeParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
    )

    @OptionGroup
    var options: CommonOptions

    @Flag
    var json: Bool = false

    func run(sakeApp: SakeApp.Type) async throws {
        let commandsPreprocessor = CommandsPreprocessor(
            commands: sakeApp.commands,
            commandGroups: sakeApp.configuration.commandGroups,
            caseConvertingStrategy: options.caseConvertingStrategy,
        )
        let rootCommands = commandsPreprocessor.rootCommands()
        let commandGroups = commandsPreprocessor.otherCommandGroups()

        let formatterInputData = CommandListFormatter.InputData(
            rootName: sakeApp.name,
            rootCommands: rootCommands,
            groupedCommands: commandGroups,
        )
        let formatted = if json {
            try CommandListFormatter.json(inputData: formatterInputData)
        } else {
            CommandListFormatter.humanReadable(inputData: formatterInputData)
        }
        print(formatted)
    }
}
