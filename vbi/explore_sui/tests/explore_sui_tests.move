/*
#[test_only]
module explore_sui::explore_sui_tests;
// uncomment this line to import the module
// use explore_sui::explore_sui;

const ENotImplemented: u64 = 0;

#[test]
fun test_explore_sui() {
    // pass
}

#[test, expected_failure(abort_code = ::explore_sui::explore_sui_tests::ENotImplemented)]
fun test_explore_sui_fail() {
    abort ENotImplemented
}
*/

module explore_sui::explore_sui_tests;

use std::ascii;
use std::debug;
use std::option::{Self, Option};
use std::string::{Self, String};
use std::unit_test::assert_eq;

// use sui::option;

// fun calc(x: &mut u64, y: &mut u64): u64 {
//     *x = 10;
//     *x + *y
// }

// fun read_and_assign(store: &mut u64, new_value: &u64) {}

// fun subtype_examples() {
//     let mut x: &u64 = &0;
//     let mut y: &mut u64 = &mut 1;

//     x = &mut 1; // valid
//     //y = &2; // ERROR! invalid!

//     read_and_assign(y, x); // valid
//     // read_and_assign(x, y); // ERROR! invalid!
// }

// fun reference_copies(s: &mut u64) {
//     let s_copy1 = s; // ok
//     //   let s_extension = &mut s.f; // also ok
//     let s_copy2 = s; // still ok
//     *s_copy2 = 42;
// }

macro fun map<$T, $U>($v: vector<$T>, $f: |$T| -> $U): vector<$U> {
    let mut v = $v;
    v.reverse();
    let mut i = 0;
    let mut result = vector[];
    while (!v.is_empty()) {
        result.push_back($f(v.pop_back()));
        i = i + 1;
    };
    result
}

/*
#[test]
fun test_sword_create() {
    // let addr_as_u256: u256 = address::to_u256(@0x1);
    // let str : String  = address::to_string(@0x1);
    // debug::print(&addr_as_u256);
    // print: 1

    // let mut x : u64 = 2;
    // let mut y : u64 = 3;
    // let result = calc(&mut x, &mut y);
    // debug::print(&x);

    // let v = vector[1, 2, 3, 4];
    // let x = *vector::borrow(&v, 2); // return ref to the 3rd element
    // debug::print(&x)

    // let ascii_string = string::from_ascii(b"Hello, world!");
    // let utf8_string = string::from_ascii(ascii_string);

    // debug::print(&utf8_string);

    // let v = vector[1, 2, 3, 4];
    // debug::print(&v);

    // let mut x: &mut u64 = &mut 0;
    // *x = 10;

    // debug::print(x);

    // subtype_examples();
    // let x : &mut u64 = &mut 0;
    // reference_copies(x);
    // debug::print(x);

    // option
    // let mut opt = option::some(b"Alice");

    // `option::none` creates an `Option` without a value. We need to specify the
    // type since it can't be inferred from context.
    // let empty: Option<u64> = option::none();
    // assert_eq!(opt.is_some(), true);
    // assert_eq!(empty.is_none(), true);

    // let mut a = vector[b'b'];
    // let b = a.length();
    // debug::print(&b);

    // let ascii_string = string::utf8(b"Hello, world!");
    // let b = ascii_string.length();
    // debug::print(&b);

}
*/

// public struct Foo has drop { x: u64, y: bool }

// #[test]
// fun test_struct() {
//     let a = Foo { x: 10, y: true };
//     let b = Foo { x: 20, y: false };
//     let c = Foo { x: 10, y: true };
//     assert_eq(&a.x, &10);
//     assert_eq(&a.y, &true);
//     assert_eq(&b.x, &20);
//     assert_eq(&b.y, &false);
//     assert_eq(&a, &c);
// }

#[test]
fun test_owner() {
    let a = 1;
    let b = a;  
    debug::print(&b);

}
