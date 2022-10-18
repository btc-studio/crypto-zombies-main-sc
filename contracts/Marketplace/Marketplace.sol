// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
<<<<<<< HEAD
<<<<<<< HEAD
    address payable public immutable receivedFeeAccount;
    uint public immutable feePercentOnSales;
=======
    // State variables
    address payable public immutable feeAccount; // The account that received fees
    uint public immutable feePercent; // The fee percentage on sales
>>>>>>> e565278... Add NFT Marketplace
=======
    address payable public immutable receivedFeeAccount;
    uint public immutable feePercentOnSales;
>>>>>>> 3aecd61... Fix comment
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
<<<<<<< HEAD
<<<<<<< HEAD
        receivedFeeAccount = payable(msg.sender); // Set the deployer to be the account that receives fees
        feePercentOnSales = _feePercent;
    }

    /// @notice List an NFT onto the Marketplace
    /// @param _nft The nft contract address
    /// @param _ft The ft contract address
    /// @param _tokenId The id of the NFT users want to sell on the Market
    /// @param _price Price of the NFT
=======
        feeAccount = payable(msg.sender); // Set the deployer to be the account that receives fees
        feePercent = _feePercent;
    }

>>>>>>> e565278... Add NFT Marketplace
=======
        receivedFeeAccount = payable(msg.sender); // Set the deployer to be the account that receives fees
        feePercentOnSales = _feePercent;
    }

    /// @notice List an NFT onto the Marketplace
    /// @param _nft The nft contract address
    /// @param _ft The ft contract address
    /// @param _tokenId The id of the NFT users want to sell on the Market
    /// @param _price Price of the NFT
>>>>>>> 3aecd61... Fix comment
    function makeItem(
        IERC721 _nft,
        IERC20 _ft,
        uint _tokenId,
        uint _price
    ) external nonReentrant {
        require(_price > 0, "Price must be greater than zero");
        // Increment itemCount
        itemCount++;
        // Transfer nft
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        // Add new item to items mapping
        items[itemCount] = Item(
            itemCount,
            _nft,
            _ft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );
        // Emit Offered event
        emit Offered(
            itemCount,
            address(_nft),
            address(_ft),
            _tokenId,
            _price,
            msg.sender
        );
    }

<<<<<<< HEAD
<<<<<<< HEAD
    /// @notice Buy an NFT on the Marketplace
    /// @param _amount The amount of BTCS user deposit to buy the NFT
    /// @param _itemId The id of the NFT users want to buy on the Market
=======
>>>>>>> e565278... Add NFT Marketplace
=======
    /// @notice Buy an NFT on the Marketplace
    /// @param _amount The amount of BTCS user deposit to buy the NFT
    /// @param _itemId The id of the NFT users want to buy on the Market
>>>>>>> 3aecd61... Fix comment
    function purchaseItem(uint _amount, uint _itemId) external nonReentrant {
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
        item.ft.transferFrom(msg.sender, item.seller, item.price);
<<<<<<< HEAD
<<<<<<< HEAD
        item.ft.transferFrom(msg.sender, receivedFeeAccount, _totalPrice - item.price);
=======
        item.ft.transferFrom(msg.sender, feeAccount, _totalPrice - item.price);
>>>>>>> e565278... Add NFT Marketplace
=======
        item.ft.transferFrom(msg.sender, receivedFeeAccount, _totalPrice - item.price);
>>>>>>> 3aecd61... Fix comment

        // Update item to sold
        item.sold = true;

        // Transfer nft to buyer
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);

        // Emit Bought event
        emit Bought(
            _itemId,
            address(item.nft),
            address(item.ft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    // Get the price set by the seller + the market fee
    function getTotalPrice(uint _itemId) public view returns (uint) {
<<<<<<< HEAD
<<<<<<< HEAD
        return ((items[_itemId].price * (100 + feePercentOnSales)) / 100);
=======
        return ((items[_itemId].price * (100 + feePercent)) / 100);
>>>>>>> e565278... Add NFT Marketplace
=======
        return ((items[_itemId].price * (100 + feePercentOnSales)) / 100);
>>>>>>> 3aecd61... Fix comment
    }
}
