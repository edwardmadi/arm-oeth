// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// Contract
import {BaseHandler} from "./BaseHandler.sol";

/// @title Distribution Handler contract
/// @dev This contract should be the only callable contract from test and will distribute calls to other contracts
/// @dev Highly inspired from Maple-Core-V2 repo: https://github.com/maple-labs/maple-core-v2
contract DistributionHandler {
    //////////////////////////////////////////////////////
    /// --- CONSTANTS && IMMUTABLES
    //////////////////////////////////////////////////////
    uint256 internal constant WEIGHTS_RANGE = 10_000;

    //////////////////////////////////////////////////////
    /// --- VARIABLES
    //////////////////////////////////////////////////////
    uint256 public numOfCallsTotal;

    address[] public targetContracts;

    uint256[] public weights;

    mapping(address => uint256) public numOfCalls;

    //////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    //////////////////////////////////////////////////////
    constructor(address[] memory targetContracts_, uint256[] memory weights_) {
        // NOTE: Order of arrays must match
        require(targetContracts_.length == weights_.length, "DH:INVALID_LENGTHS");

        uint256 weightsTotal;

        for (uint256 i; i < weights_.length; ++i) {
            weightsTotal += weights_[i];
        }

        require(weightsTotal == WEIGHTS_RANGE, "DH:INVALID_WEIGHTS");

        targetContracts = targetContracts_;
        weights = weights_;
    }

    //////////////////////////////////////////////////////
    /// --- FUNCTIONS
    //////////////////////////////////////////////////////
    function distributorEntryPoint(uint256 seed_) external {
        numOfCallsTotal++;

        uint256 range_;

        uint256 value_ = uint256(keccak256(abi.encodePacked(seed_, numOfCallsTotal))) % WEIGHTS_RANGE + 1; // 1 - 100

        for (uint256 i = 0; i < targetContracts.length; i++) {
            uint256 weight_ = weights[i];

            range_ += weight_;
            if (value_ <= range_ && weight_ != 0) {
                numOfCalls[targetContracts[i]]++;
                BaseHandler(targetContracts[i]).entryPoint(seed_);
                break;
            }
        }
    }
}
