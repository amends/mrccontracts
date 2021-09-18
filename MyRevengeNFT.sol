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
        LoveToken = _LoveToken; 
    }

    function mintNFT() public {
        require(totalSupply() < 10000, "All NFTs Minted!"); 
        Love(LoveToken).transferFrom(msg.sender, deadAddress, 10e18); //Burns 10 LOVE tokens. Oh no!!
        uint256 tokenID = totalSupply();
        _mint(msg.sender, tokenID); 

    }
    function tokenURI() public pure returns (string memory) {
    string memory URI = "https://ipfs.io/ipfs/QmZ71VbRiYeS3aYYS9ugfAmHnLiK5QzT22ttcvc1PGvY8M";
    return URI;
    }
}
