// SPDX-License-Identifier: MIT
// Zodiach Press NFT Sales Contract
//     * enables Minting of Monthly sets of six, combines into a seventh, annual auction and unlimited randoms
// Creator: Jeffrey Anthony @ Tech Enterprises

//import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/access/AccessControl.sol";

pragma solidity ^0.8.17;

/* Zodiac Signs 
    Aries, // March 21 - April 19            1616543999   
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
*/

/*enum NextSaleCurrentState {
    EMPTY_CONFIGURATION,    // 0
    CONDITIONS_CONFIGURED,  // 1
    URI_CONFIGURED,         // 2
    SALE_LOCKED_IN,         // 3
    SALE_IN_EFFECT,         // 4
    SALE_EXPIRED            // 5
}*/

/*
    int8 represents state of the creation of each month's set.
    It allows a decentralized approval process for minting new NFTs.

                0                           1               Permissions
    2*2^7
    2*2^6      Editable                    LOCKED          OWNER_ROLE
    2*2^5      Sign not yet                Sign Set        URI_ROLE
    2*2^4      Price not yet set           Price Set       MINTER_ROLE
    2*2^3      URI not yet set             URI Set         URI_ROLE
    2*2^2      Not Ready for Presale       SALE APPROVED   MINTER_ROLE
    2*2^1      Presale                     SALE STARTED
    2*2^0      Purchase still possible     SALE EXPIRED     
*/

struct ZodiachSaleData {
    string sign;
    string calendar;
    uint256 startTimestamp;
    string uri;
    uint256 price;
    int8 state;
}

abstract contract NFTSale is AccessControl {
    uint8 nextUpcomingSet = 0;

    mapping(uint16 => ZodiachSaleData) ZodiachSales;

    function createNextSale(string memory _sign, string memory _calendar)
        public
        onlyRole(keccak256("OWNER_ROLE"))
        returns (int8)
    {
        ZodiachSaleData memory newSaleData;
        newSaleData.state = NextSaleCurrentState.EMPTY_CONFIGURATION;
        newSaleData.calendar = _calendar;
        newSaleData.sign = _sign;
        ZodiachSales[nextSaleSet] = newSaleData;
        return checkNextSaleCurrentState();
    }

    function setNextSaleConditions(uint256 _timestamp, uint256 _price)
        public
        onlyRole(keccak256("MINTER_ROLE"))
        returns (int8)
    {
        ZodiachSaleData storage v = ZodiachSales[nextSaleSet];
        v.startTimestamp = _timestamp;
        v.price = _price;
        if (v.state == NextSaleCurrentState.EMPTY_CONFIGURATION) {
            v.state == NextSaleCurrentState.CONDITIONS_CONFIGURED;
        }
        return checkNextSaleCurrentState();
    }

    function setNextSaleURI(string memory _uri)
        public
        onlyRole(keccak256("URI_ROLE"))
        returns (int8)
    {
        ZodiachSaleData storage v = ZodiachSales[nextSaleSet];
        v.uri = _uri;
        if (v.state == NextSaleCurrentState.CONDITIONS_CONFIGURED) {
            v.state == NextSaleCurrentState.URI_CONFIGURED;
        }
        return checkNextSaleCurrentState();
    }

    function checkNextSaleCurrentState()
        public
        view
        onlyRole(keccak256("OWNER_ROLE"))
        returns (uint8)
    {
        return ZodiachSales[nextUpcomingSet].state;
    }

    function lockInNextSaleState() public onlyRole(keccak256("MINTER_ROLE")) {
        ZodiachSaleData storage v = ZodiachSales[nextSaleSet];
        require(
            v.state == NextSaleCurrentState.CONDITIONS_CONFIGURED,
            "ZodiachSale: Next Sale Conditions not set"
        );
        require(
            v.state == NextSaleCurrentState.URI_CONFIGURED,
            "ZodiachSale: Next Sale URI not set"
        );
        v.state = NextSaleCurrentState.SALE_LOCKED_IN;
    }

    function _beforePurchase() internal {
        // check to see which month it is
    }

    function purchaseMonthly(uint8 _option) public payable {
        _beforePurchase();
        //option = 7 will buy all six and do the combine in a single transaction
    }

    function purchaseMonthly(uint8 _option, uint16 _quantity) public payable {
        //option = 7 will buy all six and do the combine in a single transaction repeated a quantity of times
        _beforePurchase();
    }

    function purchaseMonthly(string memory _flag) public payable {
        // if flag == "all" buy all 6, do the combine, and buy all six again for the complete set in a single transaction
        _beforePurchase();
    }

    function combineMonthly() public {
        // check if caller owns six of this month's correct numbers
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

    function cancelBid() public {}
}
