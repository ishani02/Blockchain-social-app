// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

/**
 * @title IFollowModule
 * @author Lens Protocol
 *
 * @notice This is the standard interface for all Lens-compatible FollowModules.
 */
interface IFollowModule {
    /**
     * @notice Initializes a follow module for a given Lens profile. This can only be called by the hub contract.
     *
     * @param profileId The token ID of the profile to initialize this follow module for.
     * @param data Arbitrary data passed by the profile creator.
     *
     * @return bytes The encoded data to emit in the hub.
     */
    function initializeFollowModule(uint256 profileId, bytes calldata data)
        external
        returns (bytes memory);

    /**
     * @notice Processes a given follow, this can only be called from the LensHub contract.
     *
     * @param follower The follower address.
     * @param profileId The token ID of the profile being followed.
     * @param data Arbitrary data passed by the follower.
     */
    function processFollow(
        address follower,
        uint256 profileId,
        bytes calldata data
    ) external;
}
