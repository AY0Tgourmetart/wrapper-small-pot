use std::panic;
use js_sys::Promise;
use wasm_bindgen::prelude::wasm_bindgen;
use wasm_bindgen_rayon::init_thread_pool;

use wrapper_small_pot::{read_json_file, contribute_with_string, check_with_string};

#[wasm_bindgen]
pub fn init_threads(n: usize) -> Promise {
    panic::set_hook(Box::new(console_error_panic_hook::hook));
    init_thread_pool(n)
}

#[wasm_bindgen]
pub fn contribute_wasm(input: &str, string_secrets: [&str]) -> String {
    let result = contribute_with_string(
        input.to_string(),
        string_secrets
    ).unwrap();
    return format!("{}", result);
}

#[wasm_bindgen]
pub fn subgroup_check_wasm(input: &str) -> String {
    let result = check_subgroup_with_string(input).unwrap();
    return format!("{}", result);
}

// TODO: check json schema using API functions
// TODO: create update_proof_check functions