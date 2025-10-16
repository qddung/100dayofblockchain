/*
/// Module: animal_contract
module animal_contract::animal_contract;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions

module animal_contract::animal_contract;

use std::ascii::{Self, String};
use sui::coin::{Self, Coin};
use sui::object::{Self, UID};
use sui::package::{Self, Publisher};
use sui::sui::{Self, SUI};
use sui::table::{Self, Table};
use sui::tx_context::{Self, TxContext};
use sui::url::{Self, Url};

const ENotOneTimeWitness: u64 = 1;

public struct AnimalInfo has key, store {
    id: UID,
    name: String,
    species: String,
    habitat: String,
    status: u64,
    image_url: Url,
}

public struct Animals has key, store {
    id: UID,
    animal_infos: Table<u64, AnimalInfo>,
}
//Nhân viên mới sẽ có quyền để cung cấp thêm thông tin động vật
public struct NFTAdminCap has key {
    id: UID,
}

public fun add_animal(
    _: &NFTAdminCap,
    animals: &mut Animals,
    name: String,
    species: String,
    habitat: String,
    status: u64,
    image_url: String,
    ctx: &mut TxContext,
) {
    let image_url = url::new_unsafe(image_url);

    let new_animal = AnimalInfo {
        id: object::new(ctx),
        name,
        species,
        habitat,
        status,
        image_url,
    };
    let key = table::length(&animals.animal_infos);
    table::add(&mut animals.animal_infos, key, new_animal);
}

public fun update_animal(
    _: &NFTAdminCap,
    animals: &mut Animals,
    key: u64,
    new_name: String,
    new_status: u64,
    ctx: &mut TxContext,
) {
    // kiểm tra id của động vật đó là stt của động vật đó
    //assert!(table::contains(&animals.animal_infos, key), ERR_KEY_DOES_NOT_EXIST);

    let animal_info = table::borrow_mut(&mut animals.animal_infos, key);
    animal_info.name = new_name;
    animal_info.status = new_status;
}

public struct AnimalNFT has key, store {
    id: UID,
    name: String,
    animal_id: u64,
    species: String,
    habitat: String,
    adopted_by: address,
    image_url: Url,
}

public fun mint_nft(
    animals: &Animals,
    key: u64,
    inputcoin: &Coin<SUI>,
    recipient: address,
    ctx: &mut TxContext,
) {
    let animal_info = &animals.animal_infos[key];
    let new_nft = AnimalNFT {
        id: object::new(ctx),
        name: animal_info.name,
        animal_id: key,
        species: animal_info.species,
        habitat: animal_info.habitat,
        adopted_by: recipient,
        image_url: animal_info.image_url,
    };
    transfer::public_transfer(new_nft, recipient);
    
}

fun init(ctx: &mut TxContext) {
    transfer::transfer(
        NFTAdminCap { id: object::new(ctx) },
        ctx.sender(),
    )
}
