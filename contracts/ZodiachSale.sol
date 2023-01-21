// SPDX-License-Identifier: MIT
// Zodiach Press NFT Sales Contract
//     * enables Minting of Monthly sets of six, combines into a seventh, annual auction and unlimited randoms
// Creator: Jeffrey Anthony @ Tech Enterprises 

import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";


pragma solidity ^0.8.17;

uint8 nextSaleSet = 0;
uint8 currentSaleSet = 0;
/*enum ZodiacSigns {
    "Aries: March 21 - April 19",
    "Taurus: April 20 - May 20",
    "Gemini: May 21 - June 20",
    "Cancer: June 21 - July 22",
    "Leo: July 23 - August 22",
    "Virgo: August 23 - September 22",
    "Libra: September 23 - October 22",
    "Scorpio: October 23 - November 21",
    "Sagittarius: November 22 - December 21",
    "Capricorn: December 22 - January 19",
    "Aquarius: January 20 - February 18",
    "Pisces: February 19 - March 20"
}*/
enum ZodiacSigns {
    Aries,
    Taurus,
    Gemini,
    Cancer,
    Leo,
    Virgo,
    Libra,
    Scorpio,
    Sagittarius,
    Capricorn,
    Aquarius,
    Pisces
}

enum NextSaleState {
    NEW_CONFIG_STARTED,
    CONDITIONS_CONFIGURED,
    URI_CONFIGURED,
    SALE_IN_EFFECT,
    SALE_EXPIRED
}

struct ZodiachSaleData {
    ZodiacSigns sign;
    string calendar;
    uint startTimestamp;
    string uri;
    uint price;
    NextSaleState state;
}

mapping(uint16 => ZodiachSaleData) ZodiachSales;




abstract contract NFTSale is AccessControl {

    constructor() {
        createNextSale("Aries: March 21, 2022 - April 19, 2022");
        setNextSaleConditions(1616543999 , 5000000000000);
        setNextSaleURI("https://github.com/Zodiach-Press/nft-gallery");
    }

    function createNextSale(string _calendar) onlyRole("OWNER") public {
        ZodiachSaleData newSaleData = new ZodiachSaleData;
        ZodiachSales[nextSaleSet] = newSaleData;
        ZodiachSales[nextSaleSet].state = 0;
        ZodiachSales[nextSaleSet].calendar = _calendar;
        ZodiachSales[nextSaleSet].sign = nextSaleSet % 12;
    }

    function setNextSaleConditions(uint _timestamp, uint _price) onlyRole("MINTER_ROLE") public {
        ZodiachSales[nextSaleSet].startTimestamp = _timestamp;
        ZodiachSales[nextSaleSet].price = _price;
        if(ZodiachSales[nextSaleSet].state == 0) {
            ZodiachSales[nextSaleSet].state == 1;
        }
    }

    function setNextSaleURI(string _uri) onlyRole("URI_ROLE") public {
        ZodiachSales[nextSaleSet].uri = _uri;
        if(ZodiachSales[nextSaleSet].state == 1) {
            ZodiachSales[nextSaleSet].state == 2;
        }
    }

    function checkNextSaleState() onlyRole("OWNER") public returns(NextSaleState) {
        return ZodiachSales[nextSaleSet].state;
    }

    function lockInNextSaleState() onlyRole("MINTER_ROLE") public {
        require(ZodiachSales[nextSaleSet].state == 2, "ZodiachSale: URI not set");
        ZodiachSales[nextSaleSet].state = 3;
    }

    function _beforePurchase() internal {
        // check to see which month it is
        
    }

    function purchaseMonthly(uint8 _option) public {
        _beforePurchase();
        //option = 7 will buy all six and do the combine in a single transaction
    }
    function purchaseMonthly(uint8 _option, uint16 _quantity) public {
        //option = 7 will buy all six and do the combine in a single transaction repeated a quantity of times
        _beforePurchase();
    }
    function purchaseMonthly(string _flag) public { 
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

    function giftConstellation(address _to) public payable {

    }

    function giftConstellation(address _to, uint16 _quantity) public payable {
        
    }

    function submitBid(uint256 _bid) public payable {

    }

    function cancelBid() public {

    }

}
