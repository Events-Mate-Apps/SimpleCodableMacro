// The Swift Programming Language
// https://docs.swift.org/swift-book


@attached(member, names: named(init), named(CodingKeys), named(encode))
public macro Codable() = #externalMacro(module: "SimpleCodableMacros", type: "CodableMacro")
