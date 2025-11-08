module explore_sui::module_one;

/// Struct defined in the same module.
public struct Character has drop {}

/// Simple function that creates a new `Character` instance.
public fun new(): Character { Character {} }

// public entry fun create_and_ignore(ctx: &mut TxContext) {
//     let _ = new();
// }
