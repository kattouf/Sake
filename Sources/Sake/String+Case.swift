extension String {
    func toSnakeCase() -> String {
        replacingOccurrences(of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression)
            .lowercased()
    }

    func toKebabCase() -> String {
        replacingOccurrences(of: "([a-z])([A-Z])", with: "$1-$2", options: .regularExpression)
            .lowercased()
    }
}
