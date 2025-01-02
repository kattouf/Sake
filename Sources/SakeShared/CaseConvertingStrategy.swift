import ArgumentParser

package enum CaseConvertingStrategy: String, CaseIterable, ExpressibleByArgument, Decodable, Sendable {
    case keepOriginal
    case toSnakeCase
    case toKebabCase
}
