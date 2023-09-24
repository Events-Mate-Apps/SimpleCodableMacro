import Foundation
import SimpleCodable

@Codable
class MyClass {
    let myName: String
    let myAge: Int
    let myId: UUID
    let state: States
    
    internal init(myName: String, myAge: Int, myId: UUID, state: States) {
        self.myName = myName
        self.myAge = myAge
        self.myId = myId
        self.state = state
    }
}

enum States: Int, Codable {
    case old
    case yung
}
