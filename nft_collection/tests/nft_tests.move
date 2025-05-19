#[test_only]
module nft_collection::nft_tests {
    use sui::test_scenario::{Self as ts, Scenario};
    use nft_collection::nft;
    use nft_collection::nft_types::{NFT, MintCap, NFT_COLLECTION};
    use std::string;
    use sui::transfer;
    use sui::url;

    #[test]
    fun test_mint_and_transfer() {
        let admin = @0xAD;
        let user = @0xB0B;

        let scenario = ts::begin(admin);
        // Initialize the NFT contract
        {
            let ctx = ts::ctx(&mut scenario);
            nft::init(NFT_COLLECTION {}, ctx);
        };

        // Test minting an NFT
        ts::next_tx(&mut scenario, admin);
        {
            let mint_cap = ts::take_from_sender<MintCap>(&scenario);
            let ctx = ts::ctx(&mut scenario);

            let nft = nft::mint(
                &mint_cap,
                string::utf8(b"Test NFT"),
                string::utf8(b"A test NFT description"),
                b"https://example.com/nft.png",
                ctx
            );

            assert!(nft::name(&nft) == &string::utf8(b"Test NFT"), 0);
            assert!(nft::description(&nft) == &string::utf8(b"A test NFT description"), 1);
            assert!(nft::creator(&nft) == admin, 2);

            transfer::transfer(nft, user);
            ts::return_to_sender(&scenario, mint_cap);
        };

        // Verify NFT ownership
        ts::next_tx(&mut scenario, user);
        {
            let nft = ts::take_from_sender<NFT>(&scenario);
            assert!(nft::creator(&nft) == admin, 3);
            ts::return_to_sender(&scenario, nft);
        };

        ts::end(scenario);
    }
} 