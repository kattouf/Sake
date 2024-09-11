import ArgumentParser

public enum CaseConvertingStrategy: String, CaseIterable, ExpressibleByArgument, Decodable {
    case keepOriginal
    case toSnakeCase
    case toKebabCase
}
