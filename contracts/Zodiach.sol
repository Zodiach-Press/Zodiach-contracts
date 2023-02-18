// SPDX-License-Identifier: MIT
// Zodiach Press NFT Contract with URI Segmentation method
// Inherited from ERC721A Contracts v4.2.3
// Creator: Jeffrey Anthony @ Tech Enterprises 

pragma solidity ^0.8.17;

import 'https://raw.githubusercontent.com/chiru-labs/ERC721A/main/contracts/extensions/ERC721ABurnable.sol';
import 'https://raw.githubusercontent.com/chiru-labs/ERC721A/main/contracts/extensions/ERC721AQueryable.sol';
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/access/AccessControl.sol";
// import "./ZodiachSale.sol";

contract Zodiach is ERC721A(unicode'Ƶodiach Press', unicode'Ƶ'), ERC721ABurnable, ERC721AQueryable, AccessControl {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant URI_ROLE = keccak256("URI_ROLE");
    
    struct uriHelper {
        uint256 upperLimit;
        string uri;
    }
    mapping(uint256 => uriHelper) internal uriMap;

    
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC721A, IERC721A) returns (bool) {
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

    // =============================================================
    //                     URI OPERATIONS
    // =============================================================
    function tokenURI(uint256 _tokenId) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();
        return bytes(_baseURI(_tokenId)).length != 0 ? string(abi.encodePacked(_baseURI(_tokenId), "/", _toString(_tokenId))) : '';
    }

    function _baseURI(uint256 _tokenIDsought) internal view returns (string memory URI) {
        uint256 lowerLimit = 0;
        while (lowerLimit < _nextTokenId()) {
            if(lowerLimit <= _tokenIDsought && _tokenIDsought < uriMap[lowerLimit].upperLimit) return uriMap[lowerLimit].uri;
            lowerLimit = uriMap[lowerLimit].upperLimit;
        }
        
    }

    // MUST only update existing entries
    function updateURI(uint256 _lowerLimit, string memory _newURI) public onlyRole(URI_ROLE) {
        if(bytes(uriMap[_lowerLimit].uri).length !=0) uriMap[_lowerLimit].uri = _newURI;
    }

    // MUST only update ONE 'tuple'
    function allocateAndSetURIs(uint256 quantity, string memory uri) public onlyRole(MINTER_ROLE) virtual {
        require(quantity>0);
        uriMap[_nextTokenId()] = uriHelper(_nextTokenId() + quantity,uri);
    }

    // =============================================================
    //                     MINT OPERATIONS
    // =============================================================
    function mint(uint256 _quantity, string memory _uri) public onlyRole(MINTER_ROLE) {
        allocateAndSetURIs(_quantity, _uri);
        _safeMint(msg.sender, _quantity);
    }

    function mintTo(uint256 _quantity, address _mintee, string memory _uri) public onlyRole(MINTER_ROLE) {
        allocateAndSetURIs(_quantity, _uri);
        _safeMint(_mintee, _quantity);
    }
}
