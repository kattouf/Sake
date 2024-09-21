import ArgumentParser

protocol SakeParsableCommand: ParsableCommand {
    var options: CommonOptions { get }

    func run(sakeApp: SakeApp.Type) throws
}
