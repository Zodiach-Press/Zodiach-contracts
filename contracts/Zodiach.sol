// SPDX-License-Identifier: MIT
// Inherited from ERC721A Contracts v4.2.3
// Creator: Jeffrey Anthony @ Tech Enterprises 

pragma solidity ^0.8.17;

import '../node_modules/erc721a/contracts/extensions/ERC721ABurnable.sol';
import '../node_modules/erc721a/contracts/extensions/ERC721AQueryable.sol';
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";

contract Zodiach is ERC721A(unicode'Ƶodiach Press', unicode'Ƶ'), ERC721ABurnable, ERC721AQueryable, AccessControl {
    /**
     * @dev Base URI for computing {tokenURI} in 721A. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, it can be overridden in child contracts.
     */

    string private _URI;
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant URI_ROLE = keccak256("URI_ROLE");
    
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

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(URI_ROLE, msg.sender);
        _mintERC2309(msg.sender, 764);
        _URI = 'http://192.168.1.3/nft/json/';

    }

    // =============================================================
    //                     URI OPERATIONS
    // =============================================================

    function updateURI(string memory _newURI) public onlyRole(URI_ROLE) returns (bool) {
        _URI = _newURI;
        return true;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 _tokenId) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();
        return bytes(_URI).length != 0 ? string(abi.encodePacked(_URI, _toString(_tokenId), '.json')) : '';
    }

    // =============================================================
    //                     MINT OPERATIONS
    // =============================================================

    function mint(uint256 _quantity) public onlyRole(MINTER_ROLE) returns (bool) {
        _safeMint(msg.sender, _quantity);
        return true;
    }

    function mintTo(uint256 _quantity, address _mintee) public onlyRole(MINTER_ROLE) returns (bool) {
        _safeMint(_mintee, _quantity);
        return true;
    }
}