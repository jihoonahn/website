extension Hashable {
    func isAny(of candidates: Set<Self>) -> Bool {
        return candidates.contains(self)
    }
}
