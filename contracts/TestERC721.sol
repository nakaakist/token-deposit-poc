// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * Mock ERC20 token for testing purposes.
 */
contract TestERC721 is ERC721 {
    constructor() ERC721("Test", "TST") {}

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}
