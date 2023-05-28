// SPDX-License-Identifier: Unlicensed
//Chris mcgahon :p

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SampleEscrowToken is ERC20 {
    event transfered(address to, address from, uint amount);
    event mintTokens(address to, uint amount);

    constructor() ERC20("Defactor", "FACTR") {}

    function sendToken(address to) public payable {
        require(msg.sender != to, "Cannot send yourself tokens!");
        _transfer(msg.sender, to, msg.value);
        emit transfered(to, msg.sender, msg.value);
    }

    // Wrap Eth to Defactor (Out of scope)
    function mintToken() public payable {
        require(msg.value >= 0, "Value cannot be empty!");
        _mint(msg.sender, msg.value);
        emit mintTokens(msg.sender, msg.value);
    }

    function burnToken() public payable {
        _burn(msg.sender, msg.value);
        _transfer(address(this), msg.sender, msg.value);
    }
}

contract SampleEscrowNFT is ERC721 {
    constructor() ERC721("EthDublin", "EthD") {}

    uint256 idCount = 0;
    uint256 buyOrderCount = 0;

    event nftCreated(address minter);
    event creatorFunded(address fundee);

    modifier onlyOwnerOfNft() {
        _;
    }

    mapping(address => mapping(uint256 => BuyOrder)) bids;
    mapping(uint256 => NftDetails) nftStore;
    mapping(address => uint256) totalBalance;

    mapping(address => uint256[]) myOffers;

    struct BuyOrder {
        address buyer;
        uint256 ammount;
        uint256 nftID;
        bool approved;
    }

    struct NftDetails {
        address owner;
        string description;
        string ipfsHash;
    }

    BuyOrder buyOrder;
    uint256[] myOffersList;

    NftDetails nftdetails;

    function fundBeneficiary(address userToFund) public payable {
        require(msg.sender != userToFund, "Cannot fund yourself!");

        _transfer(msg.sender, userToFund, msg.value);
        totalBalance[userToFund] = msg.value;
        emit creatorFunded(userToFund);
    }

    //TODO: RemoveBuyOffer
    function submitBuyOffer(
        address buyFrom,
        uint256 buyPrice,
        uint256 nftID
    ) public {
        require(msg.sender != buyFrom, "Cannot buy your own NFT!");
        buyOrder = BuyOrder(msg.sender, buyPrice, nftID, false);

        bids[buyFrom][buyOrderCount] = buyOrder;
        myOffersList = myOffers[buyFrom];
        myOffersList.push(buyOrderCount);
        myOffers[buyFrom] = myOffersList;
        buyOrderCount++;
    }

    function checkNumberOfOffers() public view {
        myOffers[msg.sender];
    }

    function checkOfferByID(uint256 id) public view {
        bids[msg.sender][id];
    }

    function approveOffer(uint256 offerID) public {
        buyOrder = bids[msg.sender][offerID];

        _transfer(
            (bids[msg.sender][offerID]).buyer,
            msg.sender,
            buyOrder.nftID
        );
        totalBalance[msg.sender] = buyOrder.ammount;
    }

    function withdrawAll() public {
        _transfer(address(this), msg.sender, totalBalance[msg.sender]);
    }

    function mintNft(
        address _to,
        string memory description,
        string memory ipfsHash
    ) public {
        _mint(_to, idCount);
        nftdetails = NftDetails(msg.sender, description, ipfsHash);
        nftStore[idCount] = nftdetails;
        idCount++;

        emit nftCreated(msg.sender);
    }

    function mintFACTR() public {}

    function getMyBalance() public view returns (uint) {
        return totalBalance[msg.sender];
    }
}
