# Token deposit

In this repo, I tried to implement a simple token deposit pool contract.

The following tokens can be deposited and withdrawn:

- ERC20 token
- ERC721 token
- ERC1155 token
- ETH

The depositor can specify:

- token kind (ERC20, ERC721, ...)
- token contract address
- withdrawer address (can be different from depositor)
- token ID (for ERC721 and ERC1155)
- amount (for ERC20 and ETH)

## How to run

1. `pnpm install` to install dependencies
2. `pnpm test` to run tests
