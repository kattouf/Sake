enum SakeAppContents {
    static let gitignore = """
    .DS_Store
    /.build
    /.index-build
    /Packages
    xcuserdata/
    DerivedData/
    .swiftpm/configuration/registries.json
    .swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata
    .netrc
    """

    static let packageSwift = """
    // swift-tools-version: 5.10
    // The swift-tools-version declares the minimum version of Swift required to build this package.

    import CompilerPluginSupport
    import PackageDescription

    let package = Package(
        name: "SakeApp",
        platforms: [.macOS(.v13)], // Required by SwiftSyntax for the macro feature in Sake
        products: [
            .executable(name: "SakeApp", targets: ["SakeApp"]),
        ],
        dependencies: [
            .package(url: "https://github.com/kattouf/Sake", from: "0.1.0"),
        ],
        targets: [
            .executableTarget(
                name: "SakeApp",
                dependencies: [
                    "Sake",
                ],
                path: "."
            ),
        ]
    )
    """

    static let sakefile = """
    import Foundation
    import Sake

    @main
    @CommandGroup
    struct Commands: SakeApp {
        public static var hello: Command {
            Command(
                run: { _ in
                    print("Hello, world!")
                }
            )
        }
    }
    """
}
