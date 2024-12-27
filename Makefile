-include .env

clean:
	forge clean

remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :
	forge install cyfrin/foundry-devops --no-commit && forge install smartcontractkit/chainlink-brownie-contracts --no-commit && forge install foundry-rs/forge-std --no-commit

update:
	forge update

build:
	forge build

test:
	forge test

anvil:
	anvil

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
