// SPDX-License-Identifier: MIT
// Zodiach Press NFT Sales Contract
// Creator: Jeffrey Anthony @ Tech Enterprises

//import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/access/AccessControl.sol";
import "./Zodiach.sol";

pragma solidity ^0.8.17;

/* 
We're trying to build a machine that can 'perpetually' mint sets of NFTs
correctly according to plan of the stars and its creators

Zodiac Launch Date:
  March 21 - April 19               
  timestamp I believe 1616543999  
*/

struct SaleData {
    string sign;
    string calendar;
    uint256 startTimestamp;
    string uri;
    uint256 price;
    int8 state;
    uint128 qtyMinted;
    uint128 qtyBurned;
}

contract NFTSale is AccessControl, Zodiach {
    uint8 nextUpcomingSet = 0;
    uint8 currentSet = 0;
    uint256 highBid;
    mapping(uint8 => uint16) mintedMap;

    mapping(uint16 => SaleData) ZodiachSales;

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, Zodiach) returns (bool) {
        // The interface IDs are constants representing the first 4 bytes
        // of the XOR of all function selectors in the interface.
        // See: [ERC165](https://eips.ethereum.org/EIPS/eip-165)
        // (e.g. `bytes4(i.functionA.selector ^ i.functionB.selector ^ ...)`)
        return
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
            interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
            // Below is the interfaceid from AccessControl here https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol
            //interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId); 
    }
    
    constructor() {
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(URI_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, msg.sender);
        createNextSale("Aries", "March 21, 2022 - April 19, 2022");
        setSaleConditions(1616543999 , 5000000000000);
        setSaleURI("https://github.com/Zodiach-Press/nft-gallery");
        // intention is to _mintERC2309(msg.sender, 4900); ... may as well build a wrapper function the constructor could insert all data
        // may not have to at all
    }

    function createNextSale(string memory _sign, string memory _calendar)
        public
        onlyRole(keccak256("OWNER_ROLE"))
    {
        require(ZodiachSales[nextUpcomingSet].state == 0, "Error: Cannot go farther than one month ahead.");
        SaleData memory newSaleData;
        newSaleData.state = 1;
        newSaleData.calendar = _calendar;
        newSaleData.sign = _sign;
        ZodiachSales[nextUpcomingSet] = newSaleData;
    }

    function setSaleConditions(uint256 _timestamp, uint256 _price)
        public
        onlyRole(keccak256("MINTER_ROLE"))
    {
        SaleData storage v = ZodiachSales[nextUpcomingSet];
        v.startTimestamp = _timestamp;
        v.price = _price * 10^12;
        if (v.state == 1) {
            v.state = 2;
        }
    }

    function setSaleURI(string memory _uri)
        public
        onlyRole(keccak256("URI_ROLE"))
    {
        SaleData storage v = ZodiachSales[nextUpcomingSet];
        v.uri = _uri;
        if (v.state == 2) {
            v.state = 3;
        }
    }

    function returnNextSaleState() public onlyRole(keccak256("OWNER_ROLE")) view returns (string memory, string memory, uint256, uint256, string memory, int8){
        SaleData memory v = ZodiachSales[nextUpcomingSet];
        return (v.sign, v.calendar, v.startTimestamp, v.price, v.uri, v.state);
    }

    // make sure there isnt a bug that comes back in and overwrites the current sale with 'state = 1'
    function lockInNextSaleState() public onlyRole(keccak256("MINTER_ROLE")) {
        SaleData storage v = ZodiachSales[nextUpcomingSet];
        require(
            v.state > 2,
            "ZodiachSale: Next Sale Conditions not set"
        );
        require(
            v.state == 3,
            "ZodiachSale: Next Sale URI not set"
        );
        v.state = 4;
        ZodiachSales[nextUpcomingSet++].state = 1;
    }

    function _beforePurchase() internal {
        // check if it is a certain amount of ticks prior to sale and check if sender is whitelisted
        // check to see if there is a sale
        require(ZodiachSales[currentSet].state > 3, "Sale not yet begun. Patience aligns the stars.");
        if(block.timestamp > ZodiachSales[currentSet].startTimestamp ) {
            ZodiachSales[currentSet].state = 7;
        }
        if(block.timestamp > (ZodiachSales[currentSet].startTimestamp - 3 hours)) {
            ZodiachSales[currentSet].state = 6;

        }

        require(ZodiachSales[currentSet].state == 7, "Public sale not in effect.");
        require(ZodiachSales[currentSet].qtyMinted <= 4000, "SOLD OUT");
    }

    function buy(uint8 _option) public payable {
        require(msg.value > 120000000000000, "Send enough Ether");
        require(mintedMap[_option] < 700, "One or more of the selected NFTs are SOLD OUT.");
        uint256 idToMint = ((currentSet * 4900) // discover the set's range of IDs
            + (_option * 700) // add the NFT option's range of ids
            + mintedMap[_option]);  // add the individual mintId
        transferFrom(MINTER_ROLE, msg.sender, idToMint);
    }
    
    function mintConstellation() public payable {
        // be sure to mint at the end of the tokenIds
    }

    function mintConstellation(uint16 _quantity) public payable {
        // be sure to mint at the end of the tokenIds
    }

    function giftConstellation(address _to) public payable {}

    function giftConstellation(address _to, uint16 _quantity) public payable {}

    function submitBid(uint256 _bid) public payable {}

    function retrieveBid() public {}
}
