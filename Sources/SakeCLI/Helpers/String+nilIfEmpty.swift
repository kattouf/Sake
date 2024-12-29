extension String {
    func nilIfEmpty() -> Self? {
        isEmpty ? nil : self
    }
}
