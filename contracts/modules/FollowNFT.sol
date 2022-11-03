//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import {Errors} from "../../libraries/Errors.sol";
import {ERC721Time} from "../base/ERC721Time.sol";
import {IFollowNFT} from "../../interfaces/IFollowNFT.sol";
import {Constants} from "../../libraries/Constants.sol";
import {IHub} from "../../interfaces/IHub.sol";

contract FollowNFT is ERC721Time, IFollowNFT {
    address public immutable HUB;
    uint256 internal _profileId;
    uint256 internal _tokenIdCounter;
    bool private _initialized;

    constructor(address hub) {
        if (hub == address(0)) revert Errors.InitParamsInvalid();
        HUB = hub;
        _initialized = true;
    }

    function initialize(uint256 profileId) external override {
        if (_initialized) revert Errors.Initialized();
        _initialized = true;
        _profileId = profileId;
    }

    function mint(address to) external override returns (uint256) {
        if (msg.sender != HUB) revert Errors.NotHub();
        unchecked {
            uint256 tokenId = ++_tokenIdCounter;
            _mint(to, tokenId);
            return tokenId;
        }
    }

    function name() public view override returns (string memory) {
        string memory handle = IHub(HUB).getHandle(_profileId);
        return
            string(abi.encodePacked(handle, Constants.FOLLOW_NFT_NAME_SUFFIX));
    }

    function symbol() public view override returns (string memory) {
        string memory handle = IHub(HUB).getHandle(_profileId);
        bytes4 firstBytes = bytes4(bytes(handle));
        return
            string(
                abi.encodePacked(firstBytes, Constants.FOLLOW_NFT_SYMBOL_SUFFIX)
            );
    }
}
