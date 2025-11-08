// module payment::token_contract;

// use std::string::{Self, String};
// use sui::coin::{Self, Coin, TreasuryCap};
// use sui::transfer;
// use sui::tx_context::{Self, TxContext};
// use sui::balance::{Self, Balance};

// struct MYCOIN has drop {}



// struct TreasuryCapHolder has key {
//     id: UID,
//     treasury_cap: TreasuryCap<MYCOIN>,
// }


 
// fun init(otw: MYCOIN, ctx: &mut TxContext) {
//     let (treasury_cap, metadata) = coin::create_currency(
//         otw,
//         9,
//         b"MYC",
//         b"MyCoin",
//         b"My Coin description",
//         option::some(url::new_unsafe(string::utf8(bb"https://mycoin.com/logo.png"))),
//         ctx,
//     );
//     transfer::public_freeze_object(metadata);
    
//     let treasury_cap_holder = TreasuryCapHolder {
//         id: object::new(ctx),
//         treasury_cap,
//     };
//     transfer::share_object(treasury_cap_holder);
// }
 
// entry fun mint(treasury_cap_holder: &mut TreasuryCapHolder, ctx: &mut TxContext) {
//     let treasury_cap = &mut treasury_cap_holder.treasury_cap;
//     let coins = coin::mint(treasury_cap, 1000, ctx);
//     // Do something with the coins
// }
