//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IFollowModule} from "../../interfaces/IFollowModule.sol";
import {IHub} from "../../interfaces/IHub.sol";
import {Errors} from "../../libraries/Errors.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
@notice lets only those users follow a profile who are:
* 1. Approved by the profile owner
* 2. Have not followed profile earlier i.e. 1 user can follow only once
*/
contract Follow is IFollowModule {
    address HUB;

    constructor(address hub) {
        HUB = hub;
    }

    //mapping to check if the user is approved by the profile owner to follow
    mapping(address => mapping(uint256 => mapping(address => bool)))
        internal _approvedByProfileByOwner;
    //to check if user is already following the profile
    mapping(uint256 => mapping(uint256 => bool)) public isProfileFollowing;

    /**
     * @notice This follow module works on custom profile owner approvals.
     *
     * @param profileId The profile ID of the profile to initialize this module for.
     * @param data The arbitrary data parameter, decoded into:
     *      address[] addresses: The array of addresses to approve initially.
     *
     * @return bytes An abi encoded bytes parameter, which is the same as the passed data parameter.
     */
    function initializeFollowModule(uint256 profileId, bytes calldata data)
        external
        override
        returns (bytes memory)
    {
        address owner = IERC721(HUB).ownerOf(profileId);

        if (data.length > 0) {
            address[] memory addresses = abi.decode(data, (address[]));
            uint256 addressesLength = addresses.length;
            for (uint256 i = 0; i < addressesLength; ) {
                _approvedByProfileByOwner[owner][profileId][
                    addresses[i]
                ] = true;
                unchecked {
                    ++i;
                }
            }
        }
        return data;
    }

    /**
     * @dev Processes a follow by:
     *  1. Validating that the follower owns the profile passed through the data param.
     *  2. Validating that the profile that is being used to execute the follow was not already used for following the
     *     given profile.
     */
    function processFollow(
        address follower,
        uint256 profileId,
        bytes calldata data
    ) external override {
        uint256 followerProfileId = abi.decode(data, (uint256));

        if (IERC721(HUB).ownerOf(followerProfileId) != follower) {
            revert Errors.NotProfileOwner();
        }
        if (isProfileFollowing[followerProfileId][profileId]) {
            revert Errors.FollowInvalid();
        } else {
            isProfileFollowing[followerProfileId][profileId] = true;
        }
    }

    /**
     * @notice A custom function that allows profile owners to customize approved addresses.
     *
     * @param profileId The profile ID to approve/disapprove follower addresses for.
     * @param addresses The addresses to approve/disapprove for following the profile.
     * @param toApprove Whether to approve or disapprove the addresses for following the profile.
     */
    function approve(
        uint256 profileId,
        address[] calldata addresses,
        bool[] calldata toApprove
    ) external {
        if (addresses.length != toApprove.length)
            revert Errors.InitParamsInvalid();
        address owner = IERC721(HUB).ownerOf(profileId);
        if (msg.sender != owner) revert Errors.NotProfileOwner();

        uint256 addressesLength = addresses.length;
        for (uint256 i = 0; i < addressesLength; i++) {
            _approvedByProfileByOwner[owner][profileId][
                addresses[i]
            ] = toApprove[i];
        }
    }

    /**
     * @notice Returns whether the given address is approved for the profile owned by a given address.
     *
     * @param profileOwner The profile owner of the profile to query the approval with.
     * @param profileId The token ID of the profile to query approval with.
     * @param toCheck The address to query approval for.
     *
     * @return bool True if the address is approved and false otherwise.
     */
    function isApproved(
        address profileOwner,
        uint256 profileId,
        address toCheck
    ) external view returns (bool) {
        return _approvedByProfileByOwner[profileOwner][profileId][toCheck];
    }
}
