extension Character {
    var isSameLineWhitespace: Bool {
        isWhitespace && !isNewline
    }
}

extension Set where Element == Character {
    static let boldItalicStyleMarkers: Self = ["*", "_"]
    static let allStyleMarkers: Self = boldItalicStyleMarkers.union(["~"])
}
