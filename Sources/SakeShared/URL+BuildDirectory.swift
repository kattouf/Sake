import Foundation

public extension URL {
    func findBuildDirectory() -> URL? {
        var currentURL = self

        while currentURL.path != "/" {
            let buildDirectory = currentURL.appendingPathComponent(".build")
            if FileManager.default.fileExists(atPath: buildDirectory.path) {
                return buildDirectory
            }
            currentURL.deleteLastPathComponent()
        }

        return nil
    }
}
