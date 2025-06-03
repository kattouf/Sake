extension String {
    /// Shell-safe quoting for an individual argument (wraps in `"` and escapes `"` and `\`)
    var shellQuoted: String {
        let escaped = self
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }
}
