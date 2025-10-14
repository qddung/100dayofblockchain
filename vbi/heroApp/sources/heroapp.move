/*
/// Module: heroapp
module heroapp::heroapp;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions

module heroapp::heroapp;

use std::option::{Self, Option};
use sui::object::{UID, ID};

public struct SimpleWarrior has key {
    id: UID,
    sword: Option<Sword>,
    shield: Option<Shield>,
}

public struct Sword has key, store {
    id: UID,
    strength: u8,
}

public struct Shield has key, store {
    id: UID,
    armor: u8,
}



public entry fun create_warrior(ctx: &mut TxContext) {
    let warrior = SimpleWarrior {
        id: object::new(ctx),
        sword: option::none(),
        shield: option::none(),
    };
    transfer::transfer(warrior, tx_context::sender(ctx))
}

public entry fun create_sword(strength: u8, ctx: &mut TxContext) {
    let sword = Sword {
        id: object::new(ctx),
        strength,
    };

    transfer::transfer(sword, tx_context::sender(ctx))
}

public entry fun equip_sword(warrior: &mut SimpleWarrior, sword: Sword, ctx: &mut TxContext) {
    if (option::is_some(&warrior.sword)) {
        let old_sword = option::extract(&mut warrior.sword);
        transfer::transfer(old_sword, tx_context::sender(ctx));
    };

    option::fill(&mut warrior.sword, sword);
}
