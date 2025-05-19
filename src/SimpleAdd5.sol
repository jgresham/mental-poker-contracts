// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/// @title SimpleAdd5
/// @notice A simple contract that demonstrates basic arithmetic operations
contract SimpleAdd5 {
    uint256 public lastResult;

    /// @notice Returns the number 5
    /// @return The number 5
    function getFive() public pure returns (uint256) {
        return 5;
    }

    /// @notice Adds 5 to the last result
    /// @return The result of adding 5 to the last result
    function addFive() public returns (uint256) {
        lastResult = lastResult + 5;
        return lastResult;
    }
}
