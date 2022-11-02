// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./UserBase.sol";

contract DnaBase is UserBase, ERC721 {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    uint dnaDigits = 16;
    uint dnaModulus = 10**dnaDigits;
    uint cooldownTime = 1 days;

    struct Dna {
        uint id;
        uint dna;
        uint rarity; // The number of stars of the Dna
        bool isOpened; // Check if the DNA Sample has been opened or not
    }

    uint randNonce = 0;

    // dnaId -> Dna
    mapping(uint => Dna) public dnas;

    constructor(address _token)
        UserBase(_token)
        ERC721("BTCZombieNFT", "CZB")
    {}

    function randMod(uint _modulus) internal returns (uint) {
        randNonce = randNonce.add(1);
        return
            uint(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }
}
