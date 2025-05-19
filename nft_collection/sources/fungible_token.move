module nft_collection::fungible_token {
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::object::{Self, UID};
    use std::option;
    use nft_collection::fungible_token_types::{Self, MYCOIN, AdminCap};

    /// Initialize a new token type
    fun init(witness: MYCOIN, ctx: &mut TxContext) {
        // Create the token with initial supply 0
        let (treasury, metadata) = coin::create_currency(
            witness,
            9, // Decimals
            b"MYCOIN", // Symbol
            b"My Token", // Name
            b"Token Description", // Description
            option::none(), // Icon URL
            ctx
        );

        // Transfer the treasury cap and metadata to the sender
        transfer::transfer(treasury, tx_context::sender(ctx));
        transfer::public_freeze_object(metadata);

        // Create and transfer AdminCap to sender
        transfer::transfer(
            AdminCap { id: object::new(ctx) },
            tx_context::sender(ctx)
        );
    }

    /// Mint new tokens
    public fun mint(
        treasury_cap: &mut TreasuryCap<MYCOIN>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient);
    }

    /// Burn tokens
    public fun burn(
        treasury_cap: &mut TreasuryCap<MYCOIN>,
        coin: Coin<MYCOIN>
    ) {
        coin::burn(treasury_cap, coin);
    }

    /// Merge two coins
    public fun join(coin1: &mut Coin<MYCOIN>, coin2: Coin<MYCOIN>) {
        coin::join(coin1, coin2);
    }

    /// Split a coin into two coins
    public fun split(
        coin: &mut Coin<MYCOIN>,
        split_amount: u64,
        ctx: &mut TxContext
    ): Coin<MYCOIN> {
        coin::split(coin, split_amount, ctx)
    }

    /// Transfer coins to recipient
    public fun transfer(coin: Coin<MYCOIN>, recipient: address) {
        transfer::public_transfer(coin, recipient)
    }

    /// Get the balance of a coin
    public fun balance(coin: &Coin<MYCOIN>): u64 {
        coin::value(coin)
    }
}