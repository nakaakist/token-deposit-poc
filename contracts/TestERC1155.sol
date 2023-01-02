// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/**
 * Mock ERC1155 token for testing purposes.
 */
contract TestERC1155 is ERC1155 {
    constructor() ERC1155("https://example.com") {}

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) public {
        _mint(to, tokenId, amount, "");
    }
}
