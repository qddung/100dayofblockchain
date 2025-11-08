module nft_collection::fungible_token_types {
    use sui::object::UID;

    /// The type identifier of our token
    public struct MYCOIN has drop {}

    /// Capability that grants permission to mint and burn tokens
    public struct AdminCap has key {
        id: UID
    }
} 