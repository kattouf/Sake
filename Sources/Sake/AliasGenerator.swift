enum AliasGenerator {
    static func generateAliases(for phrases: [String], specificPrefixes: [String: [String: Int]] = [:]) -> [String: String] {
        let phrases = phrases.filter { !$0.isEmpty }
        let aliases = phrases.map { generateAlias(for: $0, specificPrefixPerWord: specificPrefixes[$0] ?? [:]) }
        if aliases.count == Set(aliases).count {
            return Dictionary(uniqueKeysWithValues: zip(phrases, aliases))
        } else {
            var specificPrefixes = specificPrefixes
            var colidedAliasesToPhrases = [String: [String]]()
            for (phrase, alias) in zip(phrases, aliases) {
                if colidedAliasesToPhrases[alias] == nil {
                    colidedAliasesToPhrases[alias] = [phrase]
                } else {
                    colidedAliasesToPhrases[alias]?.append(phrase)
                }
            }
            for phrases in colidedAliasesToPhrases.values {
                if phrases.count > 1 {
                    let wordsForPhrases = phrases.map(splitPhraseToWords(_:))
                    let numberOfWordsPerPhrase = wordsForPhrases.map(\.count).min() ?? 0
                    let specificPrefixPerWord = (0 ..< numberOfWordsPerPhrase).reduce(into: [String: Int]()) { result, index in
                        let sameIndexWords = wordsForPhrases.map { $0[index] }
                        if Set(sameIndexWords).count == 1 {
                            return
                        }
                        let commonPrefix = commonPrefix(sameIndexWords)
                        for word in sameIndexWords {
                            result[word] = commonPrefix.count + 1
                        }
                    }
                    for phrase in phrases {
                        specificPrefixes[phrase] = specificPrefixPerWord
                    }
                }
            }

            return generateAliases(for: phrases, specificPrefixes: specificPrefixes)
        }
    }

    private static func generateAlias(for phrase: String, specificPrefixPerWord: [String: Int]) -> String {
        let words = splitPhraseToWords(phrase)
        let firstLetters = words.compactMap { $0.prefix(specificPrefixPerWord[$0] ?? 1) }
        return firstLetters.joined()
    }

    private static func splitPhraseToWords(_ phrase: String) -> [String] {
        let snakeCaseName = phrase.toSnakeCase()
        return snakeCaseName.split(separator: "_").map(String.init)
    }

    private static func commonPrefix(_ strings: [String]) -> String {
        guard let first = strings.first else {
            return ""
        }
        return strings.dropFirst().reduce(first) { prefix, string in
            prefix.commonPrefix(with: string)
        }
    }
}
