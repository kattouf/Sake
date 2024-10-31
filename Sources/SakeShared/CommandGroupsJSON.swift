import Foundation

public struct CommandGroupsJSON: Codable {
    public struct Command: Codable {
        public let name: String
        public let description: String?

        public init(name: String, description: String?) {
            self.name = name
            self.description = description
        }
    }

    public let groups: [String: [Command]]

    public init(groups: [String: [Command]]) {
        self.groups = groups
    }
}
