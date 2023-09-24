import Foundation
import SimpleCodable

class MyClass {
    let myName: String
    let myCrush: String?
    let myAge: Int
    let myId: UUID
    let state: States
    
    internal init(
        myName: String,
        myCrush: String? = nil,
        myAge: Int,
        myId: UUID,
        state: States
    ) {
        self.myName = myName
        self.myCrush = myCrush
        self.myAge = myAge
        self.myId = myId
        self.state = state
    }
}

enum States: Int, Codable {
    case old
    case yung
}
