// SPDX-License-Identifier: MIT
// Zodiach Press NFT Sales Contract
//     * enables Minting of Monthly sets of six, combines into a seventh, annual auction and unlimited randoms
// Creator: Jeffrey Anthony @ Tech Enterprises

//import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/access/AccessControl.sol";
import "./Zodiach.sol";

pragma solidity ^0.8.17;

/* Some helpful charts I needed to build this darned contraption
We're trying to build a machine that can 'perpetually' mint sets of NFTs
correctly according to plan of the stars and the creators

Zodiac Signs and 2022 - 2023 cycle Dates and timestamps
    Aries, // March 21 - April 19               1616543999   
    Taurus, // April 20 - May 20
    Gemini, // May 21 - June 20
    Cancer, // June 21 - July 22
    Leo, // July 23 - August 22
    Virgo, // August 23 - September 22
    Libra, // September 23 - October 22
    Scorpio, // October 23 - November 21
    Sagittarius, // November 22 - December 21
    Capricorn, // December 22 - January 19
    Aquarius, // January 20 - February 18
    Pisces // February 19 - March 20
Each limited set set has a lifecycle integrated thusly...
    NULL                    // 0
    EMPTY_CONFIGURATION,    // 1
    CONDITIONS_SET,         // 2
    URI_SET,                // 3
    SALE_APPROVED / LOCKED  // 4 // triggers next EMPTY_CONFIGURATION
    PRIOR_TO_SALE ,         // 5
    WHITELIST_SALE          // 6
    PUBLIC_SALE             // 7
    SALE_EXPIRED            // 8
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
    }

    function createNextSale(string memory _sign, string memory _calendar)
        public
        onlyRole(keccak256("OWNER_ROLE"))
        returns (int8)
    {
        SaleData memory newSaleData;
        newSaleData.state = 1;
        newSaleData.calendar = _calendar;
        newSaleData.sign = _sign;
        ZodiachSales[nextUpcomingSet] = newSaleData;
        return checkState();
    }

    function setSaleConditions(uint256 _timestamp, uint256 _price)
        public
        onlyRole(keccak256("MINTER_ROLE"))
        returns (int8)
    {
        SaleData storage v = ZodiachSales[nextUpcomingSet];
        v.startTimestamp = _timestamp;
        v.price = _price * 10^12;
        if (v.state == 1) {
            v.state = 2;
        }
        return checkState();
    }

    function setSaleURI(string memory _uri)
        public
        onlyRole(keccak256("URI_ROLE"))
        returns (int8)
    {
        SaleData storage v = ZodiachSales[nextUpcomingSet];
        v.uri = _uri;
        if (v.state == 2) {
            v.state = 3;
        }
        return checkState();
    }

    function checkState()
        public
        view
        onlyRole(keccak256("OWNER_ROLE"))
        returns (int8)
    {
        return ZodiachSales[nextUpcomingSet].state;
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
        ZodiachSales[nextUpcomingSet + 1].state = 1;

    }

    function _beforePurchase() internal view returns (uint16) {
        // check if it is a certain amount of ticks prior to sale and check if sender is whitelisted
        // check to see if there is a sale and return the set number
        require(ZodiachSales[currentSet].state == 7, "Sale not in effect");
        require(ZodiachSales[currentSet].qtyMinted <= 4900, "SOLD OUT");
        return currentSet;
    }

    function purchaseMonthly(uint8[] memory _option) public payable {
        uint16 set = _beforePurchase();
        //option = 7 will burn six and award the seventh in a single transaction with combine event
        if(_option[0] == 7) {

        }

        //option = 12 will buy all seven and burn the next seven with combine event // perhaps rename 'combine'
        if(_option[0] == 12) {
            
        }
        for(uint8 i = 0; i < _option.length; i++) {

        }

    }

    function purchaseMonthly(uint8 _option, uint16 _quantity) public payable {
        //option = 7 will buy all six and do the combine in a single transaction repeated a quantity of times
        _beforePurchase();
    }

    function combineMonthly(uint16 _monthNumber) public {
        // check if caller owns six of the correct month numbers
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
