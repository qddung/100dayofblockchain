#[test_only]
module hello_contract::hello_world_tests_copy;

use std::debug;
use std::option::{Self, Option};
use std::string::{Self, String};
use sui::bcs;
use sui::object::{Self, UID};
use sui::tx_context;

public struct User has key, store {
    id: UID,
}

#[test]
public fun test_func() {
    let mut ctx = tx_context::dummy();
    let a: User = User { id: object::new(&mut ctx) };
    let id_address = object::id(&a);
    debug::print(&id_address);
    // a.id.id = object::new(&mut ctx);


    let User { id } = a;
    object::delete(id);
}
