import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// Implementation of the `Codable` macro.
public struct CodableMacro: MemberMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            let structError = Diagnostic(
                node: attribute,
                message: MyLibDiagnostic.notAClass
            )
            context.diagnose(structError)
            return []
        }
        let members = classDecl.memberBlock.members
        let variableDecls = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let bindings = variableDecls.flatMap { $0.bindings }
        let patterns = bindings.compactMap {$0.pattern.as(IdentifierPatternSyntax.self) }
        
        let clause = InheritanceClauseSyntax {
            InheritedTypeSyntax(type: "String" as TypeSyntax)
            InheritedTypeSyntax(type: "CodingKey" as TypeSyntax)
        }
        let codingKeys = EnumDeclSyntax(name: "CodingKeys", inheritanceClause: clause) {
            for pattern in patterns {
                "case \(raw: pattern.identifier.text)"
            }
        }
        
        var text = "let container = try decoder.container(keyedBy: CodingKeys.self)\n"
        for binding in bindings {
            guard
                let pattern = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                let type = binding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type
            else {
                continue
            }
            
            if let typeAnnotation = type.as(IdentifierTypeSyntax.self)?.name.text {
                /// Non optional value
                let toReturn = """
                    self.\(pattern) = try container.decode(\(typeAnnotation).self, forKey: .\(pattern))\n
                """
                    text.append(toReturn)
            } else if let typeAnnotation = type.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.text {
                /// Optional value
                let toReturn = """
                    self.\(pattern) = try container.decodeIfPresent(\(typeAnnotation).self, forKey: .\(pattern))\n
                """
                    text.append(toReturn)
            } else if let typeAnnotation = type.as(ArrayTypeSyntax.self)?.element.as(IdentifierTypeSyntax.self)?.name.text {
                /// Array Value
                /// Decoding array. If the key doesn't exist, it will be set to an empty array
                let toReturn = """
                    self.\(pattern) = (try container.decode([\(typeAnnotation)].self, forKey: .\(pattern))) ?? []\n
                """
                    text.append(toReturn)
            } else if let typeAnnotation = type.as(OptionalTypeSyntax.self)?.wrappedType.as(ArrayTypeSyntax.self)?.element.as(IdentifierTypeSyntax.self)?.name.text {
                /// Optional Array Value
                /// Decoding Optional array. If the key doesn't exist, it will be set to an empty array

                let toReturn = """
                    self.\(pattern) = try container.decodeIfPresent([\(typeAnnotation)].self, forKey: .\(pattern))\n
                """
                    text.append(toReturn)
            }
        }
        
        let decoderInitializer = try InitializerDeclSyntax("public required init(from decoder: Decoder) throws") {
            "\(raw: text)"
        }
        
        var encoder = "var container = encoder.container(keyedBy: CodingKeys.self)\n"
        for binding in bindings {
            guard
                let pattern = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                continue
            }
        let toReturn = """
            try container.encode(\(pattern), forKey: .\(pattern))\n
        """
            encoder.append(toReturn)
        }
        
        let encoderFunction = try FunctionDeclSyntax("public func encode(to encoder: Encoder) throws") {
            "\(raw: encoder)"
        }
        
        return [
            DeclSyntax(codingKeys),
            DeclSyntax(decoderInitializer),
            DeclSyntax(encoderFunction)
        ]
    }
    
    enum MyLibDiagnostic: String, DiagnosticMessage {
        case notAClass
        
        var severity: DiagnosticSeverity { return .error }
        
        var message: String {
            switch self {
            case .notAClass:
                return "'@MyMacroMacro' can only be applied to a 'class'"
            }
        }
        
        var diagnosticID: MessageID {
            MessageID(domain: "MyLibMacros", id: rawValue)
        }
    }
}

@main
struct SimpleCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CodableMacro.self
    ]
}
