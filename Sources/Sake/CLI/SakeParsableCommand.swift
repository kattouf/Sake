import ArgumentParser

protocol SakeParsableCommand: ParsableCommand {
    func run(sakeApp: SakeApp.Type) async throws
}
