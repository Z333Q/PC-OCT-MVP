// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./OracleManagement.sol";
import "./TreasuryManagement.sol";
import "./PriceCalculation.sol";
import "./AccessControlManager.sol";
import "./BridgeOperations.sol";

contract PuckCity is OracleManagement, TreasuryManagement, PriceCalculation, AccessControlManager, BridgeOperations {
    constructor(
        address _puckToken,
        address _rootChainManager
    ) TreasuryManagement(_puckToken) BridgeOperations(_rootChainManager) {
        // Constructor code
    }

    // Function to purchase PUCK tokens
    function purchasePuck(uint256 amount) external payable whenNotPaused nonReentrant {
        uint256 currentPrice = getCurrentPrice(
            getReserveBalance(),
            getTotalWins(),
            getTotalLosses(),
            getTotalPlayoffTeams(),
            getTotalEliminatedTeams(),
            getPlayoffDemandFactor(),
            getEliminationDemandFactor(),
            getTransactionFee(),
            getTotalRevenueFromTransactionFees(),
            getTotalRevenueFromClaimFees(),
            totalSupply()
        );
        require(msg.value >= currentPrice * amount, "Insufficient ether sent");
        mintPuckTokens(msg.sender, amount);
    }

    // Function to convert PUCK to CITY tokens
    function convertPuckToCity(uint256 amount, string memory cityName) external whenNotPaused nonReentrant {
        uint256 cityTokenId = getCityTokenId(cityName);
        require(cityTokenId != 0, "City not found");
        require(getPuckBalance(msg.sender) >= amount, "Insufficient PUCK tokens");
        burnPuckTokens(msg.sender, amount);
        mintCityTokens(msg.sender, cityTokenId, amount);
    }

    // Function to claim tokens
    function claimToken(uint256 _teamId) external nonReentrant whenNotPaused {
        require(_teamId < TEAM_COUNT, "Invalid team ID");
        uint256 balance = getCityBalance(msg.sender, _teamId);
        require(balance > 0, "No tokens to claim");
        processClaim(msg.sender, _teamId, balance);
    }

    // Function to set game results
    function setGameResult(
        uint256 _teamId,
        uint256 _gameId,
        uint256 _homeScore,
        uint256 _awayScore,
        bool _teamMadePlayoff,
        bool _teamEliminated
    ) external onlyRole(GAME_ADMIN_ROLE) {
        updateGameResult(_teamId, _gameId, _homeScore, _awayScore, _teamMadePlayoff, _teamEliminated);
    }

   // Function to withdraw from the global treasury
    function withdrawFromGlobalTreasury(uint256 _amount) external onlyOwner {
        require(_amount <= getGlobalTreasuryBalance(), "Insufficient balance in global treasury");
        transferFundsFromTreasury(msg.sender, _amount);
    }

    // Update token price
    function updateTokenPrice() external {
        uint256 newPrice = calculateNewPrice(
            getTotalTradingVolume(),
            getGlobalTreasuryBalance(),
            getTotalWins(),
            getTotalLosses(),
            getTotalPlayoffTeams(),
            getTotalEliminatedTeams(),
            getPlayoffDemandFactor(),
            getEliminationDemandFactor(),
            getTransactionFee(),
            getTotalRevenueFromTransactionFees(),
            getTotalRevenueFromClaimFees(),
            totalSupply()
        );
        emit PriceUpdated(newPrice);  // Emitting price update event
    }

    // Migrate ERC20 tokens to Polygon
    function migrateERC20ToPolygon(uint256 _amount) external onlyOwner {
        depositERC20ToPolygon(msg.sender, _amount);
    }

    // Lock tokens for bridging operations
    function lockTokens(uint256[] memory _ids, uint256[] memory _amounts) external onlyRole(BRIDGE_ROLE) {
        bridgeLockTokens(msg.sender, _ids, _amounts);
    }

    // Unlock tokens from bridging operations
    function unlockTokens(address _user, uint256[] memory _ids, uint256[] memory _amounts) external onlyRole(BRIDGE_ROLE) {
        bridgeUnlockTokens(_user, _ids, _amounts);
    }

    // Chainlink function to request game results
    function requestGameResult(uint256 _teamId, uint256 _gameId) external onlyOwner returns (bytes32 requestId) {
        requestId = requestGameResultsFromOracle(_teamId, _gameId);
    }

    // Function to handle Chainlink responses
    function fulfill(
        bytes32 _requestId,
        uint256 _teamId,
        uint256 _gameId,
        uint256 _score
    ) external onlyOracle {
        updateGameScoreFromOracle(_requestId, _teamId, _gameId, _score);
    }

    // Functions to control contract state
    function pause() external onlyOwner {
        pauseContract();
    }

    function unpause() external onlyOwner {
        unpauseContract();
    }

    modifier onlyOracle() {
        require(isOracle(msg.sender), "Not authorized");
        _;
    }