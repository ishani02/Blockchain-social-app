//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {DataTypes} from "../libraries/DataTypes.sol";
import {Errors} from "../libraries/Errors.sol";
import {Storage} from "../libraries/Storage.sol";
import {ERC721Time} from "./base/ERC721Time.sol";
import {PublishingLogic} from "../libraries/PublishingLogic.sol";
import {InteractionLogic} from "../libraries/InteractionLogic.sol";
import {IHub} from "../interfaces/IHub.sol";

contract Hub is ERC721Time, Storage, IHub {
    DataTypes.ProtocolState private _state;

    /**
     * @dev This modifier reverts if the caller is not the configured governance address.
     */
    modifier onlyGov() {
        _validateCallerIsGovernance();
        _;
    }

    modifier whenPublishingEnabled() {
        _validatePublishingEnabled();
        _;
    }

    modifier whenNotPaused() {
        if (_state == DataTypes.ProtocolState.Paused) revert Errors.Paused();
        _;
    }

    // ********* GOVERNANCE FUNCTIONS **********
    function setGovernance(address newGovernance)
        external
        override
        whenNotPaused
        onlyGov
    {
        _setGovernance(newGovernance);
    }

    function setEmergencyAdmin(address newEmergencyAdmin)
        external
        override
        onlyGov
    {
        _emergencyAdmin = newEmergencyAdmin;
    }

    function setState(DataTypes.ProtocolState newState) external override {
        if (msg.sender == _emergencyAdmin) {
            if (newState == DataTypes.ProtocolState.Unpaused)
                revert Errors.EmergencyAdminCannotUnpause();
            _validateNotPaused();
        } else if (msg.sender != _governance) {
            revert Errors.NotGovernanceOrEmergencyAdmin();
        }
        _setState(newState);
    }

    function whitelistProfileCreator(address profileCreator, bool whitelist)
        external
        override
    {
        _profileCreatorWhitelisted[profileCreator] = whitelist;
    }

    // ********* PROFILE RELATED FUNCTIONS **********
    function createProfile(DataTypes.CreateProfileData calldata vars)
        external
        override
        whenNotPaused
        returns (uint256)
    {
        if (!_profileCreatorWhitelisted[msg.sender])
            revert Errors.ProfileCreatorNotWhitelisted();
        uint256 profileId = ++_profileCounter;
        _mint(vars.to, profileId);
        PublishingLogic.createProfile(
            vars,
            profileId,
            _profileIdByHandleHash,
            _profileById,
            _followModuleWhitelisted
        );
        return profileId;
    }

    function setFollowModule(
        uint256 profileId,
        address followModule,
        bytes calldata followModuleInitData
    ) external override whenNotPaused {
        _validateCallerIsProfileOwner(profileId);
        PublishingLogic.setFollowModule(
            profileId,
            followModule,
            followModuleInitData,
            _profileById[profileId],
            _followModuleWhitelisted
        );
    }

    function post(DataTypes.PostData calldata vars)
        external
        override
        whenPublishingEnabled
        returns (uint256)
    {
        _validateCallerIsProfileOwnerOrDispatcher(vars.profileId);
        return _createPost(vars.profileId, vars.contentURI);
    }

    function comment(DataTypes.CommentData calldata vars)
        external
        whenPublishingEnabled
        returns (uint256)
    {
        _validateCallerIsProfileOwnerOrDispatcher(vars.profileId);
        return _createComment(vars);
    }

    function follow(uint256[] calldata profileIds, bytes[] calldata datas)
        external
        override
        whenNotPaused
        returns (uint256[] memory)
    {
        return
            InteractionLogic.follow(
                msg.sender,
                profileIds,
                datas,
                _profileById,
                _profileIdByHandleHash
            );
    }

    function getHandle(uint256 profileId)
        external
        view
        override
        returns (string memory)
    {
        return _profileById[profileId].handle;
    }

    // ******** INTERNAL FUNCTIONS *********
    function _validateCallerIsProfileOwnerOrDispatcher(uint256 profileId)
        internal
        view
    {
        if (
            msg.sender == ownerOf(profileId) ||
            msg.sender == _dispatcherByProfile[profileId]
        ) {
            return;
        }
        revert Errors.NotProfileOwnerOrDispatcher();
    }

    function _validateCallerIsProfileOwner(uint256 profileId) internal view {
        if (msg.sender != ownerOf(profileId)) revert Errors.NotProfileOwner();
    }

    function _createPost(uint256 profileId, string memory contentURI)
        internal
        returns (uint256)
    {
        unchecked {
            uint256 pubId = ++_profileById[profileId].pubCount;
            PublishingLogic.createPost(
                profileId,
                contentURI,
                pubId,
                _pubByIdByProfile
            );
            return pubId;
        }
    }

    function _createComment(DataTypes.CommentData memory vars)
        internal
        returns (uint256)
    {
        unchecked {
            uint256 pubId = ++_profileById[vars.profileId].pubCount;
            PublishingLogic.createComment(
                vars,
                pubId,
                _profileById,
                _pubByIdByProfile
            );
            return pubId;
        }
    }

    function _setGovernance(address newGovernance) internal {
        _governance = newGovernance;
    }

    function _validateCallerIsGovernance() internal view {
        if (msg.sender != _governance) revert Errors.NotGovernance();
    }

    function _validateNotPaused() internal {
        if (_state == DataTypes.ProtocolState.Paused) revert Errors.Paused();
    }

    function _setState(DataTypes.ProtocolState newState) internal {
        _state = newState;
    }

    function _validatePublishingEnabled() internal view {
        if (_state != DataTypes.ProtocolState.Unpaused) {
            revert Errors.PublishingPaused();
        }
    }
}
