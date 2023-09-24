import Foundation
import SimpleCodable

@Codable
class MyClass {
    internal init(myName: String, myCrush: String? = nil, favoriteCountries: [String], inLoveWith: [String]? = nil, myAge: Int, myId: UUID, state: States, pets: [Dog]) {
        self.myName = myName
        self.myCrush = myCrush
        self.favoriteCountries = favoriteCountries
        self.inLoveWith = inLoveWith
        self.myAge = myAge
        self.myId = myId
        self.state = state
        self.pets = pets
    }
    
    let myName: String
    let myCrush: String?
    let favoriteCountries: [String]
    let inLoveWith: [String]?
    let myAge: Int
    let myId: UUID
    let state: States
    let pets: [Dog]
}

class Dog: Codable {
    let name: String
    let age: Int
    let isPerfect: Bool
    let id: String?
}

enum States: Int, Codable {
    case old
    case yung
}
