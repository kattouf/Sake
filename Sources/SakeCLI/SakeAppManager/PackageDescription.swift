import Foundation

struct PackageDescription: Decodable {
    let products: [Product]
}

extension PackageDescription {
    struct Product: Decodable {
        let name: String
        let type: ProductType
    }

    enum ProductType: Decodable {
        case executable
        case other(String)

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: DynamicCodingKey.self)

            guard container.allKeys.count == 1 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected only one key of product type"))
            }

            let key = container.allKeys[0].stringValue
            switch key {
            case "executable":
                self = .executable
            default:
                self = .other(key)
            }
        }

        var isExecutable: Bool {
            if case .executable = self {
                return true
            }
            return false
        }
    }
}
