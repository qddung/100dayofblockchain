/*
#[test_only]
module hello_world::hello_world_tests;
// uncomment this line to import the module
// use hello_world::hello_world;

const ENotImplemented: u64 = 0;

#[test]
fun test_hello_world() {
    // pass
}

#[test, expected_failure(abort_code = ::hello_world::hello_world_tests::ENotImplemented)]
fun test_hello_world_fail() {
    abort ENotImplemented
}
*/

#[test_only]
module hello_world::hello_world_tests;

#[test]
fun test_hello_world() {
    use sui::test_scenario;
    use sui::test_utils::assert_eq;
    use hello_world::hello_world::{HelloWorldObject, hello_world};
    use std::string;
    let dummy_address = @0xCAFE;

    // First transaction executed by initial owner to create the sword
    let mut scenario = test_scenario::begin(dummy_address);
    {
        // Create hello world
        hello_world(scenario.ctx());
    };

    scenario.next_tx(dummy_address);
    {
        let hello = scenario.take_from_sender<HelloWorldObject>();
        let text = hello.get_text();
        std::debug::print(&text);
        assert_eq(text, string::utf8(b"Hello World!"));

        scenario.return_to_sender(hello)
    };

    scenario.end();
}
