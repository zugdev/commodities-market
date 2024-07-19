// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOpenOracleCommonDataFeed {
    function latestRoundData(uint8 taskType) external view returns (bytes memory result, uint256 sd, uint256 timestamp, uint32 startBlock, uint32 endBlock);
    function requestNewReport(uint8 taskType) external;
}