import Foundation

package struct CommandGroupsJSON: Codable {
    package struct Command: Codable {
        package let name: String
        package let description: String?

        package init(name: String, description: String?) {
            self.name = name
            self.description = description
        }
    }

    package let groups: [String: [Command]]

    package init(groups: [String: [Command]]) {
        self.groups = groups
    }
}
