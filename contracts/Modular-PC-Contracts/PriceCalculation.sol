// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract PriceCalculation is AccessControl {
    bytes32 public constant PRICE_ADMIN_ROLE = keccak256("PRICE_ADMIN_ROLE");

    uint256 public constant BASE = 10**8;
    uint256 public totalTradingVolume;

    event PriceUpdated(uint256 newPrice);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);  // Set deployer as the default admin
    }

    // Function to calculate the price
    function _calculatePrice(
        uint256 tradingVolume,
        uint256 reserveBalance,
        uint256 totalWins,
        uint256 totalLosses,
        uint256 totalPlayoffTeams,
        uint256 totalEliminatedTeams,
        uint256 playoffDemandFactor,
        uint256 eliminationDemandFactor,
        uint256 transactionFee,
        uint256 totalRevenueFromTransactionFees,
        uint256 totalRevenueFromClaimFees,
        uint256 totalSupply
    ) internal pure returns (uint256) {
        uint256 winRatio = (totalWins * BASE * BASE) / (totalWins + totalLosses);
        uint256 reserveRatio = (reserveBalance * BASE) / totalSupply;
        uint256 demandFactor = BASE + playoffDemandFactor * totalPlayoffTeams * BASE / totalSupply - eliminationDemandFactor * totalEliminatedTeams * BASE / totalSupply;
        uint256 feeFactor = BASE + transactionFee * totalRevenueFromTransactionFees * BASE / totalSupply + transactionFee * totalRevenueFromClaimFees * BASE / totalSupply;

        uint256 price = (tradingVolume * BASE / totalSupply) *
                        winRatio *
                        reserveRatio *
                        demandFactor *
                        feeFactor /
                        (BASE * BASE * BASE * BASE * BASE);  // Dividing by BASE^5 to correct for the five multiplications above

        return price;
    }

    // Function to get the current price
    function getCurrentPrice(
        uint256 reserveBalance,
        uint256 totalWins,
        uint256 totalLosses,
        uint256 totalPlayoffTeams,
        uint256 totalEliminatedTeams,
        uint256 playoffDemandFactor,
        uint256 eliminationDemandFactor,
        uint256 transactionFee,
        uint256 totalRevenueFromTransactionFees,
        uint256 totalRevenueFromClaimFees,
        uint256 totalSupply
    ) public view returns (uint256) {
        return _calculatePrice(
            totalTradingVolume,
            reserveBalance,
            totalWins,
            totalLosses,
            totalPlayoffTeams,
            totalEliminatedTeams,
            playoffDemandFactor,
            eliminationDemandFactor,
            transactionFee,
            totalRevenueFromTransactionFees,
            totalRevenueFromClaimFees,
            totalSupply
        );
    }

    // Function to update the total trading volume
    function updateTotalTradingVolume(uint256 newTotalTradingVolume) public onlyRole(PRICE_ADMIN_ROLE) {
        totalTradingVolume = newTotalTradingVolume;
    }
}
