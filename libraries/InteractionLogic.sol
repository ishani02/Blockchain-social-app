//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";
import {Errors} from "./Errors.sol";
import {IFollowNFT} from "../interfaces/IFollowNFT.sol";
import {IFollowModule} from "../interfaces/IFollowModule.sol";
import {FollowNFT} from "../contracts/modules/FollowNFT.sol";

library InteractionLogic {
    /**
     * @notice Follows the given profiles, executing the necessary logic and module calls before minting the follow
     * NFT(s) to the follower.
     *
     * @param follower The address executing the follow.
     * @param profileIds The array of profile token IDs to follow.
     * @param followModuleDatas The array of follow module data parameters to pass to each profile's follow module.
     * @param _profileById A pointer to the storage mapping of profile structs by profile ID.
     * @param _profileIdByHandleHash A pointer to the storage mapping of profile IDs by handle hash.
     *
     * @return uint256[] An array of integers representing the minted follow NFTs token IDs.
     */
    function follow(
        address follower,
        uint256[] calldata profileIds,
        bytes[] calldata followModuleDatas,
        mapping(uint256 => DataTypes.ProfileStruct) storage _profileById,
        mapping(bytes32 => uint256) storage _profileIdByHandleHash
    ) external returns (uint256[] memory) {
        if (profileIds.length != followModuleDatas.length)
            revert Errors.ArrayMismatch();
        uint256[] memory tokenIds = new uint256[](profileIds.length);
        for (uint256 i = 0; i < profileIds.length; i++) {
            string memory handle = _profileById[profileIds[i]].handle;
            if (
                _profileIdByHandleHash[keccak256(bytes(handle))] !=
                profileIds[i]
            ) revert Errors.TokenDoesNotExist();

            address followModule = _profileById[profileIds[i]].followModule;
            address followNFT = _profileById[profileIds[i]].followNFT;

            if (followNFT == address(0)) {
                followNFT = _deployFollowNFT(profileIds[i]);
                _profileById[profileIds[i]].followNFT = followNFT;
            }

            tokenIds[i] = IFollowNFT(followNFT).mint(follower);

            if (followModule != address(0)) {
                IFollowModule(followModule).processFollow(
                    follower,
                    profileIds[i],
                    followModuleDatas[i]
                );
            }
        }
        return tokenIds;
    }

    /**
     * @notice Deploys the given profile's Follow NFT contract.
     *
     * @param profileId The token ID of the profile which Follow NFT should be deployed.
     *
     * @return address The address of the deployed Follow NFT contract.
     */
    function _deployFollowNFT(uint256 profileId) private returns (address) {
        address followNFT = address(new FollowNFT(msg.sender));
        return followNFT;
    }
}
