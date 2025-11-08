module payment::my_token;

use sui::coin::{Self, Coin, TreasuryCap};
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use sui::url;



// pool: Coin + TreasuryCap + Balance;
// Witness struct for the token, used for one-time currency creation
public struct MY_TOKEN has drop {}

// Initialize the token with a given supply
fun init(witness: MY_TOKEN, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency(
        witness, // Witness type for the token
        18, // Decimals
        b"MTK", // Symbol
        b"MyToken", // Name
        b"A custom fungible token on Sui blockchain", // Description
        option::some(url::new_unsafe_from_bytes(b"https://example.com/icon.png")), // Optional icon URL
        ctx,
    );

    // Transfer the treasury capability to the sender (contract deployer)
    transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    // Share the metadata object for public access
    transfer::public_share_object(metadata);
}

// Mint new tokens (only callable by the treasury capability owner)
public entry fun mint(
    treasury_cap: &mut TreasuryCap<MY_TOKEN>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    let coin = coin::mint(treasury_cap, amount, ctx);
    transfer::public_transfer(coin, recipient);
}

// Transfer tokens to a recipient
public entry fun transfer(coin: Coin<MY_TOKEN>, recipient: address, _ctx: &mut TxContext) {
    transfer::public_transfer(coin, recipient);
}

// Get the balance of a coin object
public fun balance(coin: &Coin<MY_TOKEN>): u64 {
    coin::value(coin)
}

// Burn tokens (destroy them)
public entry fun burn(
    treasury_cap: &mut TreasuryCap<MY_TOKEN>,
    coin: Coin<MY_TOKEN>,
    _ctx: &mut TxContext,
) {
    coin::burn(treasury_cap, coin);
}

// Optional: Get the total supply of the token
public fun total_supply(treasury_cap: &TreasuryCap<MY_TOKEN>): u64 {
    coin::total_supply(treasury_cap)
}
