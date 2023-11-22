#[starknet::interface]
trait IHelloStarknet<TContractState> {
    fn increase_balance(ref self: TContractState, amount: felt252);
    fn get_balance(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod HelloStarknet {
    use starknet::ContractAddress;
    use openzeppelin::access::ownable::Ownable;
    
    component!(path: Ownable, storage: Ownable_owner, event: OwnershipTransferred);

    #[abi(embed_v0)]
    impl OwnableImpl = Ownable::OwnableImpl<ContractState>;

    impl OwnableInternalImpl = Ownable::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        balance: felt252, 
        #[substorage(v0)]
        Ownable_owner: Ownable::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipTransferred: Ownable::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.Ownable_owner.initializer(owner);
    }

    #[external(v0)]
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'Amount cannot be 0');
            self.Ownable_owner.assert_only_owner();
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}
