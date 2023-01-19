// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    address payable public immutable receivedFeeAccount;
    uint public immutable feePercentOnSales;
    uint public itemCount;

    struct Item {
        uint itemId;
        IERC721 nft; // Instance of the NFT Contract associated with the NFT -> Address of the NFT Contract
        IERC20 ft; // Instance of the FT Contract associated with the FT -> Address of the FT Contract
        uint tokenId;
        uint price;
        address payable seller;
        bool sold;
    }

    event Offered(
        uint itemId,
        address indexed nft,
        address ft,
        uint tokenId,
        uint price,
        address indexed seller
    );

    event Unoffered(uint itemId, address indexed nft, uint tokenId);

    event Bought(
        uint itemId,
        address indexed nft,
        address ft,
        uint tokenId,
        uint price,
        address indexed seller,
        address indexed buyer
    );

    // itemId -> Item
    mapping(uint => Item) public items;

    constructor(uint _feePercent) {
        receivedFeeAccount = payable(msg.sender); // Set the deployer to be the account that receives fees
        feePercentOnSales = _feePercent;
    }

    /// @notice List an NFT onto the Marketplace
    /// @param _nft The nft contract address
    /// @param _ft The ft contract address
    /// @param _tokenId The id of the NFT users want to sell on the Market
    /// @param _price Price of the NFT
    function makeItem(
        IERC721 _nft,
        IERC20 _ft,
        uint _tokenId,
        uint _price,
        address senderAddress
    ) external nonReentrant {
        require(_price > 0, "Price must be greater than zero");
        itemCount++;
        // Transfer nft
        _nft.transferFrom(senderAddress, address(this), _tokenId);
        // Add new item to items mapping
        items[itemCount] = Item(
            itemCount,
            _nft,
            _ft,
            _tokenId,
            _price,
            payable(senderAddress),
            false
        );
        // Emit Offered event
        emit Offered(
            itemCount,
            address(_nft),
            address(_ft),
            _tokenId,
            _price,
            senderAddress
        );
    }

    function unmakeItem(
        IERC721 _nft,
        uint _itemId,
        address senderAddress
    ) external nonReentrant {
        Item storage item = items[_itemId];
        require(
            senderAddress == item.seller,
            "Only owner of the NFT can remove item from Marketplace"
        );

        // Transfer nft
        _nft.transferFrom(address(this), senderAddress, item.tokenId);

        // Emit Offered event
        emit Unoffered(_itemId, address(_nft), item.tokenId);

        // Remove _itemId from items mapping
        delete items[_itemId];
    }

    /// @notice Buy an NFT on the Marketplace
    /// @param _amount The amount of BTCS user deposit to buy the NFT
    /// @param _itemId The id of the NFT users want to buy on the Market
    function purchaseItem(
        uint _amount,
        uint _itemId,
        address senderAddress
    ) external nonReentrant {
        uint _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "Item doesn't exist");
        require(
            _amount >= _totalPrice,
            "Not enough BTCS to cover item price and market fee"
        );
        require(!item.sold, "Item already sold");

        // Pay seller and feeAccount
        // Accept BTCS token to purchase NFTs
        item.ft.transferFrom(senderAddress, item.seller, item.price);
        item.ft.transferFrom(
            senderAddress,
            receivedFeeAccount,
            _totalPrice - item.price
        );

        // Update item to sold
        item.sold = true;

        // Transfer nft to buyer
        item.nft.transferFrom(address(this), senderAddress, item.tokenId);

        // Emit Bought event
        emit Bought(
            _itemId,
            address(item.nft),
            address(item.ft),
            item.tokenId,
            item.price,
            item.seller,
            senderAddress
        );

        // Remove _itemId from items mapping
        delete items[_itemId];
    }

    // Get the price set by the seller + the market fee
    function getTotalPrice(uint _itemId) public view returns (uint) {
        return ((items[_itemId].price * (100 + feePercentOnSales)) / 100);
    }
}
