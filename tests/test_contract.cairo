use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use traits::TryInto;
use starknet::ContractAddress;
use starknet::Felt252TryIntoContractAddress;

use snforge_std::{declare, ContractClassTrait, start_prank};

use hello_starknet::IHelloStarknetSafeDispatcher;
use hello_starknet::IHelloStarknetSafeDispatcherTrait;

// use hello_starknet::IOwnableSafeDispatcher;
// use hello_starknet::IOwnableSafeDispatcherTrait;

const USER_OWNER:felt252 = 1024;
const USER_1:felt252 = 1;
const USER_2:felt252 = 2;

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    let mut arrs = ArrayTrait::new();
    arrs.append(USER_OWNER);
    contract.deploy(@arrs).unwrap()
}

// #[test]
// fn test_get_owner() {
//     let contract_address = deploy_contract('HelloStarknet');

//     let safe_dispatcher = IOwnableSafeDispatcher { contract_address };

//     let owner = safe_dispatcher.owner().unwrap();
//     assert(owner == 123, 'Invalid owner');
// }

#[test]
fn test_increase_balance() {
    let contract_address = deploy_contract('HelloStarknet');

    let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

    let balance_before = safe_dispatcher.get_balance().unwrap();
    assert(balance_before == 0, 'Invalid balance');

    start_prank(contract_address, USER_1.try_into().unwrap());
    start_prank(contract_address, USER_OWNER.try_into().unwrap());
    safe_dispatcher.increase_balance(42).unwrap();

    let balance_after = safe_dispatcher.get_balance().unwrap();
    assert(balance_after == 42, 'Invalid balance');
}

#[test]
fn test_cannot_increase_balance_with_zero_value() {
    let contract_address = deploy_contract('HelloStarknet');

    let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

    let balance_before = safe_dispatcher.get_balance().unwrap();
    assert(balance_before == 0, 'Invalid balance');

    match safe_dispatcher.increase_balance(0) {
        Result::Ok(_) => panic_with_felt252('Should have panicked'),
        Result::Err(panic_data) => {
            assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
        }
    };
}
