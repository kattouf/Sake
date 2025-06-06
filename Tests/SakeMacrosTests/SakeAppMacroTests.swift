import SakeMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class SakeAppMacroTests: XCTestCase {
    func testCommandGroupExpansion() {
        assertMacroExpansion(
            """
            @CommandGroup
            struct MyCommands {
                public static var hello: Command {
                    Command(
                        run: { _ in
                            print("Hello, world!")
                        }
                    )
                }

                public static var bye: Sake.Command {
                    Command(
                        run: { _ in
                            print("Bye, world!")
                        }
                    )
                }

                private var foo: Command {
                    Command(
                        run: { _ in
                            print("Some private command 1")
                        }
                    )
                }

                var bar: Command {
                    Command(
                        run: { _ in
                            print("Some private command 2")
                        }
                    )
                }

                static var xyz: Command {
                    Command(
                        run: { _ in
                            print("Some static command")
                        }
                    )
                }
            }
            """,
            expandedSource:
            """
            struct MyCommands {
                public static var hello: Command {
                    Command(
                        run: { _ in
                            print("Hello, world!")
                        }
                    )
                }

                public static var bye: Sake.Command {
                    Command(
                        run: { _ in
                            print("Bye, world!")
                        }
                    )
                }

                private var foo: Command {
                    Command(
                        run: { _ in
                            print("Some private command 1")
                        }
                    )
                }

                var bar: Command {
                    Command(
                        run: { _ in
                            print("Some private command 2")
                        }
                    )
                }

                static var xyz: Command {
                    Command(
                        run: { _ in
                            print("Some static command")
                        }
                    )
                }
            }

            extension MyCommands: Sake.CommandGroup {
                static var commands: [String: Sake.Command] {
                    [
                        "hello": Self.hello,
                        "bye": Self.bye
                    ]
                }
            }
            """,
            macros: ["CommandGroup": CommandGroupMacro.self],
        )
    }

    func testZeroCommandsMacroExpansion() {
        assertMacroExpansion(
            """
            @CommandGroup
            struct MyCommands {}
            """,
            expandedSource:
            """
            struct MyCommands {}

            extension MyCommands: Sake.CommandGroup {
                static var commands: [String: Sake.Command] {
                    [:]
                }
            }
            """,
            macros: ["CommandGroup": CommandGroupMacro.self],
        )
    }
}
