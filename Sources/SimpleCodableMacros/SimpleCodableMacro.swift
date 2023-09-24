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
                let typeAnnotation = binding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.as(IdentifierTypeSyntax.self)?.name.text
            else {
                continue
            }
        let toReturn = """
            self.\(pattern) = try container.decode(\(typeAnnotation).self, forKey: .\(pattern))\n
        """
            text.append(toReturn)
        }
        
        let decoderInitializer = try InitializerDeclSyntax("public required init(from decoder: Decoder) throws") {
            "\(raw: text)"
        }
        
        var encoder = "var container = encoder.container(keyedBy: CodingKeys.self)\n"
        for binding in bindings {
            //        self.code = try container.decode(String.self, forKey: .code)
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
