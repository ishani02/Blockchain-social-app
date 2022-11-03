//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";

abstract contract Storage {
    mapping(address => bool) internal _profileCreatorWhitelisted;
    mapping(address => bool) internal _followModuleWhitelisted;
    mapping(address => bool) internal _collectModuleWhitelisted;
    mapping(address => bool) internal _referenceModuleWhitelisted;

    mapping(uint256 => address) internal _dispatcherByProfile;
    mapping(bytes32 => uint256) internal _profileIdByHandleHash;
    mapping(uint256 => DataTypes.ProfileStruct) internal _profileById;
    mapping(uint256 => mapping(uint256 => DataTypes.PublicationStruct))
        internal _pubByIdByProfile;

    uint256 internal _profileCounter;
    address internal _governance;
    address internal _emergencyAdmin;
}
