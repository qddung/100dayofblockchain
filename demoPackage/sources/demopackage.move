/*
/// Module: demopackage
module demopackage::demopackage;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions


module demopackage::demopackage {
    use std::string;
    public fun say_hello(): string::String {
        string::utf8(b"Hello, World!")
    }
}

