/*
/// Module: todolist
module todolist::todolist;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions
module todolist::todolist;

use std::string::String;
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};

/// Cấu trúc TodoList: Một object lưu danh sách nhiệm vụ.
public struct TodoList has key, store {
    id: UID,
    items: vector<String>
}

/// Tạo TodoList mới.
public fun new(ctx: &mut TxContext): TodoList {
    TodoList {
        id: object::new(ctx),
        items: vector::empty<String>()
    }
}

/// Thêm nhiệm vụ mới vào danh sách.
public fun add(list: &mut TodoList, item: String) {
    vector::push_back(&mut list.items, item);
}

/// Xóa nhiệm vụ theo chỉ số (trả về nhiệm vụ đã xóa).
public fun remove(list: &mut TodoList, index: u64): String {
    vector::remove(&mut list.items, index)
}

/// Xóa toàn bộ danh sách.
public fun delete(list: TodoList) {
    let TodoList { id, items: _ } = list;
    object::delete(id);
}

/// Lấy độ dài danh sách.
public fun length(list: &TodoList): u64 {
    vector::length(&list.items)
}