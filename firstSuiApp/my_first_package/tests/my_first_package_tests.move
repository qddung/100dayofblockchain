/*
#[test_only]
module my_first_package::my_first_package_tests;
// uncomment this line to import the module
// use my_first_package::my_first_package;

const ENotImplemented: u64 = 0;

#[test]
fun test_my_first_package() {
    // pass
}

#[test, expected_failure(abort_code = ::my_first_package::my_first_package_tests::ENotImplemented)]
fun test_my_first_package_fail() {
    abort ENotImplemented
}
*/

#[test_only]
module my_first_package::my_first_package_tests;

use my_first_package::example::Sword;

#[test]
fun test_sword_create() {
    // Create a dummy TxContext for testing
    let mut ctx = tx_context::dummy();

    // Create a sword
    let sword = Sword {
        id: object::new(&mut ctx),
        magic: 42,
        strength: 7,
    };

    let dummy_address = @0xCAFE;
    transfer::public_transfer(sword, dummy_address);

    // Check if accessor functions return correct values
    assert!(sword.magic() == 42 && sword.strength() == 7, 1);
}
