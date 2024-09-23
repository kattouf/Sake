import ArgumentParser

struct ListCommand: SakeParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list"
    )

    @OptionGroup
    var options: CommonOptions

    @Flag
    var json: Bool = false

    func run(sakeApp: SakeApp.Type) throws {
        let commandsProvider = CommandsConvenientProvider(
            commands: sakeApp.commands,
            commandGroups: sakeApp.configuration.commandGroups,
            caseConvertingStrategy: options.caseConvertingStrategy
        )
        let rootCommands = commandsProvider.rootCommands()
        let commandGroups = commandsProvider.otherCommandGroups()

        let formatterInputData = CommandListFormatter.InputData(
            rootName: sakeApp.name,
            rootCommands: rootCommands,
            groupedCommands: commandGroups
        )
        let formatted = if json {
            try CommandListFormatter.json(inputData: formatterInputData)
        } else {
            CommandListFormatter.humanReadable(inputData: formatterInputData)
        }
        print(formatted)
    }
}
