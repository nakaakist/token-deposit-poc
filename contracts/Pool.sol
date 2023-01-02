// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract Pool is IERC721Receiver, IERC1155Receiver {
    enum TokenKind {
        ERC20,
        ERC721,
        ERC1155,
        ETH
    }

    struct Deposit {
        TokenKind tokenKind;
        address depositor;
        address withdrawer;
        address tokenAddress;
        uint256 tokenId;
        uint256 amount;
    }

    mapping(uint256 => Deposit) public deposits;

    uint256 public depositCounter;

    function deposit(
        TokenKind tokenKind,
        address tokenAddress,
        address withdrawer,
        uint256 tokenId,
        uint256 amount
    ) public payable {
        if (tokenKind == TokenKind.ERC20) {
            IERC20 tokenContract = IERC20(tokenAddress);

            require(
                tokenContract.balanceOf(msg.sender) >= amount,
                "Insufficient balance"
            );
            require(
                tokenContract.allowance(msg.sender, address(this)) >= amount,
                "Insufficient allowance"
            );

            tokenContract.transferFrom(msg.sender, address(this), amount);
        } else if (tokenKind == TokenKind.ERC721) {
            IERC721 tokenContract = IERC721(tokenAddress);

            require(
                tokenContract.ownerOf(tokenId) == msg.sender,
                "Token not owned by sender"
            );

            tokenContract.safeTransferFrom(msg.sender, address(this), tokenId);
        } else if (tokenKind == TokenKind.ERC1155) {
            IERC1155 tokenContract = IERC1155(tokenAddress);

            require(
                tokenContract.balanceOf(msg.sender, tokenId) >= amount,
                "Insufficient balance"
            );

            tokenContract.safeTransferFrom(
                msg.sender,
                address(this),
                tokenId,
                amount,
                ""
            );
        } else if (tokenKind == TokenKind.ETH) {
            require(msg.value == amount, "ETH amount mismatched");
        } else {
            revert("Invalid token kind");
        }

        uint256 depositId = depositCounter++;

        deposits[depositId] = Deposit(
            tokenKind,
            msg.sender,
            withdrawer,
            tokenAddress,
            tokenId,
            amount
        );
    }

    function withdraw(uint256 depositId) public {
        Deposit memory dep = deposits[depositId];

        require(dep.withdrawer == msg.sender, "Not authorized");

        // To prevent reentrancy, delete the deposit before transferring
        delete deposits[depositId];

        if (dep.tokenKind == TokenKind.ERC20) {
            IERC20 tokenContract = IERC20(dep.tokenAddress);

            tokenContract.approve(address(this), dep.amount);
            tokenContract.transferFrom(address(this), msg.sender, dep.amount);
        } else if (dep.tokenKind == TokenKind.ERC721) {
            IERC721 tokenContract = IERC721(dep.tokenAddress);

            tokenContract.safeTransferFrom(
                address(this),
                msg.sender,
                dep.tokenId
            );
        } else if (dep.tokenKind == TokenKind.ERC1155) {
            IERC1155 tokenContract = IERC1155(dep.tokenAddress);

            tokenContract.safeTransferFrom(
                address(this),
                msg.sender,
                dep.tokenId,
                dep.amount,
                ""
            );
        } else if (dep.tokenKind == TokenKind.ETH) {
            (msg.sender).call{value: dep.amount}("");
        } else {
            revert("Invalid token kind");
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return
            interfaceId == type(IERC721Receiver).interfaceId ||
            interfaceId == type(IERC1155Receiver).interfaceId;
    }
}
