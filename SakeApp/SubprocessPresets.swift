import Subprocess

@discardableResult
func runAndPrint(
    _ command: String,
    _ arguments: String...,
) async throws -> Subprocess.CollectedResult<FileDescriptorOutput, FileDescriptorOutput> {
    try await run(
        .name(command),
        arguments: Arguments(arguments),
        input: .fileDescriptor(.standardInput, closeAfterSpawningProcess: false),
        output: .fileDescriptor(.standardOutput, closeAfterSpawningProcess: false),
        error: .fileDescriptor(.standardError, closeAfterSpawningProcess: false),
    )
}

@discardableResult
func run(
    _ command: String, _ arguments: String...
) async throws -> Subprocess.CollectedResult<StringOutput<UTF8>, StringOutput<UTF8>> {
    try await run(
        .name(command),
        arguments: Arguments(arguments),
        input: .none,
        output: .string(limit: 512 * 1024, encoding: UTF8.self),
        error: .string(limit: 512 * 1024, encoding: UTF8.self),
    )
}
