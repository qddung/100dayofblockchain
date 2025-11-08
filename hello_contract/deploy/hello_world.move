/*
/// Module: hello_contract
module hello_contract::hello_contract;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions
module hello_contract::hello_world;

use hello_contract::consts_variant;
use std::string::{Self, String};
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context;

// use std::string::{Self, String};
// use sui::object::{Self, UID};
// use sui::transfer;
// use sui::tx_context;

/// An object that contains an arbitrary string
// public struct HelloWorldObject has key, store {
//     id: UID,
//     /// A string contained in the object
//     text: string::String,
// }

// #[lint_allow(self_transfer)]
// public entry fun hello_world(ctx: &mut TxContext) {
//     let object = HelloWorldObject {
//         id: object::new(ctx),
//         text: string::utf8(b"Hello World!"),
//     };
//     transfer::public_transfer(object, tx_context::sender(ctx));
// }

// public fun get_text(hello: &HelloWorldObject): String {
//     hello.text
// }

public struct Student has key {
    id: UID,
    name: String,
}

/// quyền admin mới tạo một sudent
public struct AdminCap has key, store { id: UID }

/// Tạo admin khi publish contract
fun init(ctx: &mut TxContext) {
    transfer::transfer(
        AdminCap { id: object::new(ctx) },
        ctx.sender(),
    )
}

/// Tạo student
public entry fun new(_: &AdminCap, name: String, ctx: &mut TxContext) {
    let student = Student {
        id: object::new(ctx),
        name,
    };

    transfer::transfer(student, ctx.sender());
}
