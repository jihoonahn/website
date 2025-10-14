func ~=<T>(rhs: KeyPath<T, Bool>, lhs: T) -> Bool {
    lhs[keyPath: rhs]
}
