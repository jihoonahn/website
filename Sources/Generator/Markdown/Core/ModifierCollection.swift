struct ModifierCollection {
    private var modifiers: [Modifier.Target : [Modifier]]

    init(modifiers: [Modifier]) {
        self.modifiers = Dictionary(grouping: modifiers, by: { $0.target })
    }

    func applyModifiers(for target: Modifier.Target,
                        using closure: (Modifier) -> Void) {
        modifiers[target]?.forEach(closure)
    }

    mutating func insert(_ modifier: Modifier) {
        modifiers[modifier.target, default: []].append(modifier)
    }
}
