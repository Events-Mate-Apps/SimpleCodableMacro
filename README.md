# SimpleCodable

Simple `Swift`'s `Codable` implementations with macros to use it with `@Model` form `SwiftData`.

## Overview

`SimpleCodable` framework exposes custom macros which can be used to generate dynamic `Codable` implementations. The core of the framework is ``Codable()`` macro which generates the implementation aided by data provided with using other macros.

`SimpleCodable` aims to just remove boilerplate code and to have `@Model` for `class` where we wanted to use automatic `Codable` generation:

- Allows to use automatic parsing using `Codable` while persist data with `SwiftData` using `@Model`.


## Requirements

| Platform | Minimum Swift Version | Installation | Status |
| --- | --- | --- | --- |
| iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ | 5.9 | Swift Package Manager | Fully Tested |
| Linux | 5.9 | Swift Package Manager | Fully Tested |
| Windows | 5.9 | Swift Package Manager | Fully Tested |

## Installation

<details>
  <summary><h3>Swift Package Manager</h3></summary>

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding `SimpleCodable` as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
.package(url: "https://github.com/Events-Mate-Apps/SimpleCodableMacro/tree/main", from: "1.0.0"),
```

Then you can add the `SimpleCodable` module product as dependency to the `target`s of your choosing, by adding it to the `dependencies` value of your `target`s.

```swift
.product(name: "SimpleCodable", package: "SimpleCodable"),
```

</details>

## Usage

`SimpleCodable` allows to get rid of boiler plate that was often needed in some typical `Codable` implementations with features like:

<details>
  <summary>Just use `SimpleCodable` with `@Codable` macro to generate `CodingKeys` and required init for `Decodable` and `Encodable`</summary>



But with `SimpleCodable` all you have to write is this:

```swift
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

```
After expansion

```swift
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

    enum CodingKeys: String, CodingKey {
        case myName
        case myAge
        case myId
        case state
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.myName = try container.decode(String.self, forKey: .myName)
        self.myAge = try container.decode(Int.self, forKey: .myAge)
        self.myId = try container.decode(UUID.self, forKey: .myId)
        self.state = try container.decode(States.self, forKey: .state)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(myName, forKey: .myName)
        try container.encode(myAge, forKey: .myAge)
        try container.encode(myId, forKey: .myId)
        try container.encode(state, forKey: .state)
    }
}
```

</details>

## Contributing

If you wish to contribute a change, suggest any improvements create issue. Or PR please :)

## License

`SimpleCodable` is released under the MIT license. [See LICENSE](LICENSE) for details.
