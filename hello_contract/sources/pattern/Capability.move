module hello_contract::capability;

use sui::object;
use sui::tx_context;
use sui::transfer;

public struct Admin has key, store {
    id: sui::object::UID,
}

public struct MyToken has key {
    id: sui::object::UID,
}

public fun do_action(_: &Admin, ctx: &mut TxContext) {
    // do something
    let _token = MyToken { id: object::new(ctx) };
    transfer::transfer(_token, tx_context::sender(ctx));
}
