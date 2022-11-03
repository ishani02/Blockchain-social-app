//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library Errors {
    error Paused();
    error ProfileCreatorNotWhitelisted();
    error HandleLengthInvalid();
    error HandleContainsInvalidCharacters();
    error ProfileImageURILengthInvalid();
    error HandleTaken();
    error FollowModuleNotWhitelisted();
    error NotProfileOwner();
    error FollowInvalid();
    error FollowNotApproved();
    error InitParamsInvalid();
    error StateAlreadySet();
    error EmergencyAdminCannotUnpause();
    error NotGovernanceOrEmergencyAdmin();
    error NotProfileOwnerOrDispatcher();
    error NotGovernance();
    error PublicationDoesNotExist();
    error CannotCommentOnSelf();
    error PublishingPaused();
    error NotHub();
    error Initialized();
    error ArrayMismatch();
    error TokenDoesNotExist();
}
