// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Love.sol";

contract MyRevengeNFT is ERC721Enumerable, ReentrancyGuard {
    
    address public LoveToken;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    constructor(address _LoveToken) ERC721("MyRevengeNFT", "REVENGENFT") {
        LoveToken = _LoveToken; //We pull in the LoveToken details
    }

    function mintNFT() public {
        require(totalSupply() < 10000, "All NFTs Minted!"); //Max Supply 10,000 NFTs
        Love(LoveToken).transferFrom(msg.sender, deadAddress, 10e18); //Burns LOVE tokens. Oh no!!
        uint256 tokenID = totalSupply() // Increment the supply. Starting at 0
        _mint(msg.sender, tokenID); // Mint the NFT

    }
    function tokenURI() public pure returns (string memory) {
    string memory URI = "https://imgur.com/iG93Nbr.jpg"; //This will be changed to ipfs link once final art is in.
    return URI;
    }
}