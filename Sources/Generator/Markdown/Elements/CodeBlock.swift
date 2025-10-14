import Foundation

struct CodeBlock: Fragment {
    var modifierTarget: Modifier.Target { .codeBlocks }

    private static let marker: Character = "`"

    private var language: Substring
    private var code: String

    static func read(using reader: inout Reader) throws -> CodeBlock {
        let startingMarkerCount = reader.readCount(of: marker)
        try require(startingMarkerCount >= 3)
        reader.discardWhitespaces()

        let language = reader
            .readUntilEndOfLine()
            .trimmingTrailingWhitespaces()

        var code = ""

        while !reader.didReachEnd {
            if code.last == "\n", reader.currentCharacter == marker {
                let markerCount = reader.readCount(of: marker)

                if markerCount == startingMarkerCount {
                    break
                } else {
                    code.append(String(repeating: marker, count: markerCount))
                    guard !reader.didReachEnd else { break }
                }
            }

            if let escaped = reader.currentCharacter.escaped {
                code.append(escaped)
            } else {
                code.append(reader.currentCharacter)
            }

            reader.advanceIndex()
        }

        return CodeBlock(language: language, code: code)
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let languageClass = language.isEmpty ? "" : " class=\"language-\(language)\""
        let highlightedCode = highlightCode(code, language: String(language))
        return "<pre><code\(languageClass)>\(highlightedCode)</code></pre>"
    }
    
    private func highlightCode(_ code: String, language: String) -> String {
        guard !language.isEmpty else { return code }
        
        switch language.lowercased() {
        case "swift":
            return highlightSwiftCode(code)
        case "javascript", "js":
            return highlightJavaScriptCode(code)
        case "python", "py":
            return highlightPythonCode(code)
        case "html":
            return highlightHTMLCode(code)
        case "css":
            return highlightCSSCode(code)
        case "json":
            return highlightJSONCode(code)
        default:
            return code
        }
    }
    
    private func highlightSwiftCode(_ code: String) -> String {
        var highlighted = code
        
        // 하이라이팅을 위한 안전한 방법: 한 번에 모든 패턴을 찾아서 처리
        var ranges: [(NSRange, String, String)] = [] // (range, type, content)
        
        // 1. 주석 찾기
        let commentPattern = "//.*$"
        if let commentRegex = try? NSRegularExpression(pattern: commentPattern, options: [.anchorsMatchLines]) {
            let commentMatches = commentRegex.matches(in: highlighted, options: [], range: NSRange(location: 0, length: highlighted.utf16.count))
            for match in commentMatches {
                let content = (highlighted as NSString).substring(with: match.range)
                ranges.append((match.range, "comment", content))
            }
        }
        
        // 2. 문자열 리터럴 찾기
        let stringPattern = "\"([^\"\\\\]|\\\\.)*\""
        if let stringRegex = try? NSRegularExpression(pattern: stringPattern, options: []) {
            let stringMatches = stringRegex.matches(in: highlighted, options: [], range: NSRange(location: 0, length: highlighted.utf16.count))
            for match in stringMatches {
                let content = (highlighted as NSString).substring(with: match.range)
                ranges.append((match.range, "string", content))
            }
        }
        
        // 3. 숫자 리터럴 찾기
        let numberPattern = "\\b\\d+(\\.\\d+)?\\b"
        if let numberRegex = try? NSRegularExpression(pattern: numberPattern, options: []) {
            let numberMatches = numberRegex.matches(in: highlighted, options: [], range: NSRange(location: 0, length: highlighted.utf16.count))
            for match in numberMatches {
                let content = (highlighted as NSString).substring(with: match.range)
                ranges.append((match.range, "number", content))
            }
        }
        
        // 4. 키워드 찾기
        let swiftKeywords = [
            "import", "class", "struct", "enum", "protocol", "extension", "func", "var", "let",
            "if", "else", "for", "while", "do", "try", "catch", "throw", "return", "break", "continue",
            "public", "private", "internal", "static", "final", "override", "required", "convenience",
            "weak", "strong", "unowned", "lazy", "mutating", "nonmutating", "inout", "indirect",
            "case", "default", "where", "guard", "defer", "repeat", "fallthrough", "switch",
            "true", "false", "nil", "self", "super", "init", "deinit", "subscript", "precedencegroup",
            "infix", "prefix", "postfix", "associativity", "left", "right", "none", "higherThan", "lowerThan"
        ]
        
        for keyword in swiftKeywords {
            let keywordPattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            if let keywordRegex = try? NSRegularExpression(pattern: keywordPattern, options: []) {
                let keywordMatches = keywordRegex.matches(in: highlighted, options: [], range: NSRange(location: 0, length: highlighted.utf16.count))
                for match in keywordMatches {
                    let content = (highlighted as NSString).substring(with: match.range)
                    ranges.append((match.range, "keyword", content))
                }
            }
        }
        
        // 범위가 겹치지 않도록 정렬하고 처리
        ranges.sort { $0.0.location < $1.0.location }
        
        // 겹치는 범위 제거
        var filteredRanges: [(NSRange, String, String)] = []
        for range in ranges {
            var hasOverlap = false
            for existing in filteredRanges {
                if NSIntersectionRange(range.0, existing.0).length > 0 {
                    hasOverlap = true
                    break
                }
            }
            if !hasOverlap {
                filteredRanges.append(range)
            }
        }
        
        // 뒤에서부터 처리하여 인덱스 변화 방지
        for range in filteredRanges.reversed() {
            let className = "token \(range.1)"
            let replacement = "<span class=\"\(className)\">\(range.2)</span>"
            highlighted = (highlighted as NSString).replacingCharacters(in: range.0, with: replacement)
        }
        
        return highlighted
    }
    
    private func highlightJavaScriptCode(_ code: String) -> String {
        var highlighted = code
        
        let jsKeywords = [
            "function", "var", "let", "const", "if", "else", "for", "while", "do", "switch", "case", "default",
            "break", "continue", "return", "try", "catch", "finally", "throw", "new", "this", "typeof",
            "instanceof", "in", "of", "class", "extends", "super", "import", "export", "from", "as",
            "async", "await", "yield", "true", "false", "null", "undefined", "NaN", "Infinity"
        ]
        
        for keyword in jsKeywords {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: highlighted.utf16.count)
            highlighted = regex?.stringByReplacingMatches(in: highlighted, options: [], range: range, withTemplate: "<span class=\"token keyword\">\(keyword)</span>") ?? highlighted
        }
        
        return highlighted
    }
    
    private func highlightPythonCode(_ code: String) -> String {
        var highlighted = code
        
        let pythonKeywords = [
            "def", "class", "if", "elif", "else", "for", "while", "try", "except", "finally", "with",
            "import", "from", "as", "return", "yield", "lambda", "and", "or", "not", "in", "is",
            "True", "False", "None", "pass", "break", "continue", "raise", "assert", "del", "global", "nonlocal"
        ]
        
        for keyword in pythonKeywords {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: highlighted.utf16.count)
            highlighted = regex?.stringByReplacingMatches(in: highlighted, options: [], range: range, withTemplate: "<span class=\"token keyword\">\(keyword)</span>") ?? highlighted
        }
        
        return highlighted
    }
    
    private func highlightHTMLCode(_ code: String) -> String {
        var highlighted = code
        
        // HTML 태그
        let tagPattern = "<(/?)([a-zA-Z][a-zA-Z0-9]*)\\b([^>]*)>"
        let tagRegex = try? NSRegularExpression(pattern: tagPattern, options: [])
        let tagRange = NSRange(location: 0, length: highlighted.utf16.count)
        highlighted = tagRegex?.stringByReplacingMatches(in: highlighted, options: [], range: tagRange, withTemplate: "<span class=\"token tag\">&lt;$1$2$3&gt;</span>") ?? highlighted
        
        return highlighted
    }
    
    private func highlightCSSCode(_ code: String) -> String {
        var highlighted = code
        
        let cssKeywords = [
            "color", "background", "margin", "padding", "border", "width", "height", "display", "position",
            "top", "right", "bottom", "left", "float", "clear", "overflow", "z-index", "opacity", "visibility",
            "font", "text", "line-height", "letter-spacing", "word-spacing", "text-align", "text-decoration",
            "text-transform", "white-space", "vertical-align", "list-style", "table", "border-collapse",
            "border-spacing", "caption-side", "empty-cells", "table-layout", "content", "quotes", "counter-reset",
            "counter-increment", "resize", "cursor", "outline", "box-shadow", "text-shadow", "transform",
            "transition", "animation", "flex", "grid", "align", "justify", "order", "flex-grow", "flex-shrink"
        ]
        
        for keyword in cssKeywords {
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: highlighted.utf16.count)
            highlighted = regex?.stringByReplacingMatches(in: highlighted, options: [], range: range, withTemplate: "<span class=\"token property\">\(keyword)</span>") ?? highlighted
        }
        
        return highlighted
    }
    
    private func highlightJSONCode(_ code: String) -> String {
        var highlighted = code
        
        // JSON 키
        let keyPattern = "\"([^\"]+)\"\\s*:"
        let keyRegex = try? NSRegularExpression(pattern: keyPattern, options: [])
        let keyRange = NSRange(location: 0, length: highlighted.utf16.count)
        highlighted = keyRegex?.stringByReplacingMatches(in: highlighted, options: [], range: keyRange, withTemplate: "<span class=\"token property\">\"$1\"</span>:") ?? highlighted
        
        // JSON 문자열 값
        let stringPattern = ":\\s*\"([^\"]+)\""
        let stringRegex = try? NSRegularExpression(pattern: stringPattern, options: [])
        let stringRange = NSRange(location: 0, length: highlighted.utf16.count)
        highlighted = stringRegex?.stringByReplacingMatches(in: highlighted, options: [], range: stringRange, withTemplate: ": <span class=\"token string\">\"$1\"</span>") ?? highlighted
        
        // JSON 숫자
        let numberPattern = ":\\s*(\\d+(\\.\\d+)?)"
        let numberRegex = try? NSRegularExpression(pattern: numberPattern, options: [])
        let numberRange = NSRange(location: 0, length: highlighted.utf16.count)
        highlighted = numberRegex?.stringByReplacingMatches(in: highlighted, options: [], range: numberRange, withTemplate: ": <span class=\"token number\">$1</span>") ?? highlighted
        
        return highlighted
    }

    func plainText() -> String {
        code
    }
}
