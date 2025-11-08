/*
#[test_only]
module hello_contract::hello_contract_tests;
// uncomment this line to import the module
// use hello_contract::hello_contract;

const ENotImplemented: u64 = 0;

#[test]
fun test_hello_contract() {
    // pass
}

#[test, expected_failure(abort_code = ::hello_contract::hello_contract_tests::ENotImplemented)]
fun test_hello_contract_fail() {
    abort ENotImplemented
}
*/

// tests/hello_world_tests.move

#[test_only]
module hello_contract::hello_world_tests;

use std::debug;
use std::string::{Self, String};

// #[test]
// fun test_hello_world() {
//     use sui::test_scenario;
//     use sui::test_utils::assert_eq;
//     use hello_contract::hello_world::{HelloWorldObject, hello_world};
//     use std::string;
//     let dummy_address = @0xCAFE;

//     // First transaction executed by initial owner to create the sword
//     let mut scenario = test_scenario::begin(dummy_address);
//     {
//         // Create hello world
//         hello_world(scenario.ctx());
//     };

//     scenario.next_tx(dummy_address);
//     {
//         let hello = scenario.take_from_sender<HelloWorldObject>();
//         let text = hello.get_text();
//         std::debug::print(&text);
//         assert_eq(text, string::utf8(b"Hello World!"));

//         scenario.return_to_sender(hello)
//     };

//     scenario.end();
// }

// fun getSum(mut x: u64): u64 {
//     let mut sum = 0;
//     loop {
//         sum = sum + x;
//         x = x - 1;
//         if (x == 0) {
//             break;
//         };
//     };
//     sum
// }

// #[test]
// fun tes_loop() {
//     //     let a = 1;
//     // let b = a * (a - 1);
//     let mut x: u64 = 100;
//     let res = getSum(x);
//     let ans = x * (x + 1) / 2;
//     assert!(res == ans, 1);
//     // debug::print(&res);

// }
// #[test]
// fun test_if_else() {
//     let x = 7;

//     // // thay vi viet nhu the nay
//     // if(x> 0){
//     //     y = 1;
//     // } else {
//     //     y = 0;
//     // }

//     // ta co the viet the nay

//     let y = if (x < 5) {
//         1
//     } else if (x < 10 && x > 5) {
//         2
//     } else {
//         3
//     };

//     debug::print(&y)
// }

// public fun t0(): std::ascii::String { b"hello" }

fun chanle(x: u64): String {
    match (x % 2) {
        1 => string::utf8(b"chan"),
        0 => string::utf8(b"le"),
        x => string::utf8(b"not found"),
    }
}

public fun foo(mut v: u64): u64 {
    v + 5
}

// macro fun my_assert($cond: bool, $code: u64) {
//     if (!$cond) abort $code;
// }

public fun test_macro() {
    let mut v = vector[1, 2, 3, 4, 5];

    let mut value = 0;
    v.reverse();

    while (!v.is_empty()) {
        value = foo(v.pop_back());

        debug::print(&v);
        debug::print(&value);
    }
}

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

public struct Point has drop {
    x: u64,
    y: u64,
}


#[test]
fun test_loop() {
    /** loop*/
    // 'outer: loop {
    //     debug::print(&(string::utf8(b"The outer loop!")));

    //     'inner: loop {
    //         debug::print(&(string::utf8(b"The inner loop")));

    //         // lệnh break dứoi này chỉ có thể break ở vòng lặp bên trong do không có nhãn
    //         //break

    //         // lệnh này sẽ break vòng lặp ở bên ngoài
    //         break 'outer;
    //     };

    //     debug::print(&(string::utf8(b"Inf loop")));
    // }

    // debug::print(&(string::utf8(b"The outer loop!")));

    //* condition*/
    let x = 1;
    // let y: String = if (x % 2 == 0) {
    //     string::utf8(b"chan")
    // } else {
    //     string::utf8(b"le")
    // };
    // debug::print(&y);

    // pattern matching

    // let r = chanle(x);
    // debug::print(&r);
    // test_macro();

    // value
    // let mut point = Point { x: 1, y: 2 };
    // point.x = 2;
    // debug::print(&point);
}
