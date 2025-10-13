/*
/// Module: library
module library::library;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions

module library::library;

use std::string::{Self, String};
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};

//https://sui-bootcamp-2024.vercel.app/object_programming/Module_Initializers
public struct LibraryCard has key {
    // Todo: điền các trường
    id: UID,
    name: String,
    book_count: u8,
}
public struct AdminCapability has key, store {
    // Todo: điền các trường
    id: UID,
}

public entry fun create_library_card(
    _: &AdminCapability,
    name: String,
    book_count: u8,
    ctx: &mut TxContext,
) {
    let card = LibraryCard {
        id: object::new(ctx),
        name,
        book_count,
    };
    transfer::transfer(card, tx_context::sender(ctx));
}

fun init(ctx: &mut TxContext) {
    let admin_cap = AdminCapability {
        id: object::new(ctx),
    };
    let first_card = LibraryCard {
        id: object::new(ctx),
        name: string::utf8(b"Library System"),
        book_count: 0,
    };
    // send the admin capability to the tx sender
    transfer::transfer(admin_cap, tx_context::sender(ctx));
    transfer::transfer(first_card, tx_context::sender(ctx));
}
