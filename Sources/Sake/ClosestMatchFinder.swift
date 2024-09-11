final class ClosestMatchFinder {
    private let candidates: [String]

    init(candidates: [String]) {
        self.candidates = candidates
    }

    func findClosestMatches(to input: String, maxDistance: Int = 2) -> [String] {
        var nearMatches: [String] = []

        for candidate in candidates {
            let distance = levenshteinDistance(input, candidate)
            if distance <= maxDistance {
                nearMatches.append(candidate)
            }
        }

        return nearMatches
    }

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Count = s1.count
        let s2Count = s2.count

        var matrix = [[Int]](repeating: [Int](repeating: 0, count: s2Count + 1), count: s1Count + 1)

        for i in 0 ... s1Count {
            matrix[i][0] = i
        }

        for j in 0 ... s2Count {
            matrix[0][j] = j
        }

        for i in 1 ... s1Count {
            for j in 1 ... s2Count {
                let s1Index = s1.index(s1.startIndex, offsetBy: i - 1)
                let s2Index = s2.index(s2.startIndex, offsetBy: j - 1)

                if s1[s1Index] == s2[s2Index] {
                    matrix[i][j] = matrix[i - 1][j - 1]
                } else {
                    matrix[i][j] = min(
                        matrix[i - 1][j] + 1, // Deletion
                        matrix[i][j - 1] + 1, // Insertion
                        matrix[i - 1][j - 1] + 1 // Substitution
                    )
                }
            }
        }

        return matrix[s1Count][s2Count]
    }
}
