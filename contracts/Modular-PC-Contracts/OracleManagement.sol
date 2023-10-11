// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract OracleManagement is ChainlinkClient, AccessControl {
    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");

    // Struct to encapsulate oracle details for cleaner code
    struct OracleDetails {
        bytes32 jobId;
        uint256 fee;
        address oracleAddress;
    }

    OracleDetails public oracleDetails;

    event OracleDetailsUpdated(
        bytes32 indexed jobId,
        uint256 fee,
        address indexed oracleAddress
    );

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);  // Set deployer as the default admin
    }

    // Function to set oracle details
    function setOracleDetails(
        bytes32 _jobId,
        uint256 _fee,
        address _oracleAddress
    ) public onlyRole(ORACLE_ADMIN_ROLE) {
        oracleDetails = OracleDetails({
            jobId: _jobId,
            fee: _fee,
            oracleAddress: _oracleAddress
        });
        emit OracleDetailsUpdated(_jobId, _fee, _oracleAddress);
    }

    // Function to get the latest price
    function requestPriceData() public onlyRole(ORACLE_ADMIN_ROLE) returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(
            oracleDetails.jobId,
            address(this),
            this.fulfill.selector
        );

        // Set the URL and path for the API request (this is just a placeholder and might need to be adjusted)
        request.add("get", "https://api.priceapi.io/v4/price");
        request.add("path", "data.price");  // Adjust the path to get the desired data

        // Sends the request
        return sendChainlinkRequestTo(oracleDetails.oracleAddress, request, oracleDetails.fee);
    }

    // Function to handle Chainlink responses
    function fulfill(bytes32 _requestId, uint256 _price) public recordChainlinkFulfillment(_requestId) {
        // Handle the price data (e.g., update a state variable, emit an event, etc.)
    }
}
