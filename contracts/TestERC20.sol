// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * Mock ERC20 token for testing purposes.
 */
contract TestERC20 is ERC20 {
    constructor() ERC20("Test", "TST") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
