import Sake
import SwiftShell

func interruptableRunAndPrint(bash command: String, interruptionHandler: Command.Context.InterruptionHandler) throws {
    let asyncCommand = runAsyncAndPrint(bash: command)
    interruptionHandler.register(asyncCommand)
    try asyncCommand.finish()
}
