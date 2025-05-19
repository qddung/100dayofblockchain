module nft_collection::nft_types {
    use sui::object::UID;
    use std::string::String;
    use sui::url::Url;

    /// An NFT that can be minted by the creator
    public struct NFT has key, store {
        id: UID,
        name: String,
        description: String,
        image_url: Url,
        creator: address,
    }

    /// Capability that grants permission to mint NFTs
    public struct MintCap has key, store {
        id: UID
    }

    /// One-Time-Witness for the module
    public struct NFT_COLLECTION has drop {}

    // ===== Events =====
    public struct NFTMinted has copy, drop {
        nft_id: address,
        creator: address,
        name: String,
    }
}

module nft_collection::nft {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::package;
    use sui::display;
    use sui::event;
    use std::string::{Self, String};
    use sui::url::{Self, Url};
    use nft_collection::nft_types::{Self, NFT, MintCap, NFT_COLLECTION, NFTMinted};

    // ===== Public Functions =====
    
    fun init(witness: NFT_COLLECTION, ctx: &mut TxContext) {
        // Create the MintCap and transfer it to the deployer
        let mint_cap = MintCap {
            id: object::new(ctx)
        };
        transfer::transfer(mint_cap, tx_context::sender(ctx));

        // Set up Display for better marketplace presentation
        let publisher = package::claim(witness, ctx);
        let display = display::new<NFT>(&publisher, ctx);
        
        display::add(&mut display, string::utf8(b"name"), string::utf8(b"{name}"));
        display::add(&mut display, string::utf8(b"description"), string::utf8(b"{description}"));
        display::add(&mut display, string::utf8(b"image_url"), string::utf8(b"{image_url}"));
        display::add(&mut display, string::utf8(b"creator"), string::utf8(b"{creator}"));

        display::update_version(&mut display);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    /// Create a new NFT
    public fun mint(
        _: &MintCap,
        name: String,
        description: String,
        image_url: vector<u8>,
        ctx: &mut TxContext
    ): NFT {
        let sender = tx_context::sender(ctx);
        
        let nft = NFT {
            id: object::new(ctx),
            name,
            description,
            image_url: url::new_unsafe_from_bytes(image_url),
            creator: sender,
        };

        // Emit mint event
        event::emit(NFTMinted {
            nft_id: object::uid_to_address(&nft.id),
            creator: sender,
            name: name,
        });

        nft
    }

    /// Transfer an NFT to a recipient
    public fun transfer(nft: NFT, recipient: address) {
        transfer::transfer(nft, recipient)
    }

    // ===== View Functions =====

    /// Get the NFT's name
    public fun name(nft: &NFT): &String {
        &nft.name
    }

    /// Get the NFT's description
    public fun description(nft: &NFT): &String {
        &nft.description
    }

    /// Get the NFT's image URL
    public fun image_url(nft: &NFT): &Url {
        &nft.image_url
    }

    /// Get the NFT's creator
    public fun creator(nft: &NFT): address {
        nft.creator
    }
} 