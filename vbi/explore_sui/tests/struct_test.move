module explore_sui::struct_tests;

use std::debug;
use std::string::{Self, String};
use sui::object::{Self, UID};

/**
key: UID
store: 
copy:
drop:

*/

public struct DropMe has copy, drop {
    id: u8,
    name: String,
}

/// This struct doesn't have the `drop` ability.
// public struct NoDrop {
//     id: u8,
//     name: String,
// }

// #[test]
// fun test_ignore() {
//     let dr = DropMe { id: 1, name: string::utf8(b"sui_bootcamp") };

//     let dr1 = dr;
//     let no_drop = NoDrop { id: 1, name: string::utf8(b"sui_bootcamp") };
//     let NoDrop { id: idd, name: _ } = no_drop;
//     debug::print(&dr);
// }
public enum SimpleEnum has drop {
    Variant1(u64),
    Variant2(u64),
}
public fun incr_enum_variant1(simple_enum: &mut SimpleEnum) {

    match (simple_enum) {
        SimpleEnum::Variant1(mut value) => *value = *value + 1,
        _ => (),
    }
}
public fun incr_enum_variant2(simple_enum: &mut SimpleEnum) {
    match (simple_enum) {
        SimpleEnum::Variant2(mut value) => *value = *value + 1,
        _ => (),
    }
}

#[test]
public  fun example_enum(){
    let mut x = SimpleEnum::Variant1(10);
    incr_enum_variant1(&mut x);
    debug::print(&x);
}
