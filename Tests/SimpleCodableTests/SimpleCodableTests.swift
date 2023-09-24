import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SimpleCodableMacros

let testMacros: [String: Macro.Type] = [
    "Codable" : CodableMacro.self,
]

final class SimpleCodableTest: XCTestCase {
    func testCodable() {
        assertMacroExpansion(
            """
            @Codable
            class MyClass {
                let myName: String
                let myAge: Int
                let myCrush: String?
                let favoriteCountries: [String]
                let inLoveWith: [String]?
                let myId: UUID
                let state: States
            }
            """,
            expandedSource: """
            class MyClass {
                let myName: String
                let myAge: Int
                let myCrush: String?
                let favoriteCountries: [String]
                let inLoveWith: [String]?
                let myId: UUID
                let state: States

                enum CodingKeys: String, CodingKey {
                    case myName
                    case myAge
                    case myCrush
                    case favoriteCountries
                    case inLoveWith
                    case myId
                    case state
                }

                public required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.myName = try container.decode(String.self, forKey: .myName)
                    self.myAge = try container.decode(Int.self, forKey: .myAge)
                    self.myCrush = try container.decodeIfPresent(String.self, forKey: .myCrush)
                    self.favoriteCountries = try container.decode([String].self, forKey: .favoriteCountries)
                    self.inLoveWith = try container.decodeIfPresent([String].self, forKey: .inLoveWith)
                    self.myId = try container.decode(UUID.self, forKey: .myId)
                    self.state = try container.decode(States.self, forKey: .state)
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(myName, forKey: .myName)
                    try container.encode(myAge, forKey: .myAge)
                    try container.encode(myCrush, forKey: .myCrush)
                    try container.encode(favoriteCountries, forKey: .favoriteCountries)
                    try container.encode(inLoveWith, forKey: .inLoveWith)
                    try container.encode(myId, forKey: .myId)
                    try container.encode(state, forKey: .state)
                }
            }
            """,
            macros: testMacros
        )
    }
}
