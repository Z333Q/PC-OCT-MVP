// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TokenManagement is ERC20, ERC1155 {
    using Counters for Counters.Counter;

    Counters.Counter private _totalWins;

    uint256 private constant GAMES_IN_SEASON = 82;
    uint256 private constant TEAM_COUNT = 32;
    uint256 private constant TOKENS_PER_TEAM = 1000;
    uint256 private constant PERCENT_MULTIPLIER = 1000;  // For 0.5% transaction fee
    uint256 private constant PUCK_PRICE = 1 ether;  // Assume 1 ether for simplicity

    // Mapping from city name to CITY token ID
    mapping(string => uint256) public cityToTokenId;
    // Mapping from CITY token ID to city name
    mapping(uint256 => string) public tokenIdToCity;
    mapping(uint256 => uint256) public reserves;

    constructor() ERC20("Puck City", "PUCK") ERC1155("") {
        // Initialize cityToTokenId and tokenIdToCity mappings
        // Assuming city names and token IDs are 1-indexed for simplicity
        for (uint256 i = 1; i <= TEAM_COUNT; i++) {
            string memory cityName = generateCityName(i);  // Assume this function generates city names
            cityToTokenId[cityName] = i;
            tokenIdToCity[i] = cityName;
        }
    }

    function generateCityName(uint256 index) internal pure returns (string memory) {
        // Assume this function generates city names based on index
        return string(abi.encodePacked("City", uint2str(index)));
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    // Function to purchase PUCK tokens
    function purchasePuck(uint256 amount) external payable {
        require(msg.value >= PUCK_PRICE * amount, "Insufficient ether sent");
        _mint(msg.sender, amount);
    }

    // Function to convert PUCK to CITY tokens
    function convertPuckToCity(uint256 amount, string memory cityName) external {
        uint256 cityTokenId = cityToTokenId[cityName];
        require(cityTokenId != 0, "City not found");
        require(balanceOf(msg.sender) >= amount, "Insufficient PUCK tokens");
        _burn(msg.sender, amount);
        _mint(msg.sender, cityTokenId, amount, "");
    }
}
