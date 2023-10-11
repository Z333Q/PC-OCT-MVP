// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// External library imports
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@maticnetwork/pos-portal/contracts/root/RootChainManager.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "https://github.com/Immutable-X/imx-contracts/blob/master/contracts/ERC20.sol";

contract PuckCity is ERC20, ERC1155, Ownable, Pausable, ReentrancyGuard, ChainlinkClient, Initializable, AccessControl {
    using Counters for Counters.Counter;
    RootChainManager public rootChainManager;
    IERC1155 public polygonERC1155;

    event TokenPurchased(address indexed buyer, uint256 amount, uint256 teamId);
    event TokenClaimed(address indexed claimer, uint256 amount, uint256 teamId);
    event GameResultUpdated(uint256 indexed teamId, uint256 indexed gameId, uint256 homeScore, uint256 awayScore);



// Constants
uint256 public constant PUCK = 0;
    uint256 public puckPrice = 1 ether;  // Price of PUCK token in wei
    uint256 private constant GAMES_IN_SEASON = 82;
    uint256 private constant TEAM_COUNT = 32;
    uint256 private constant TOKENS_PER_TEAM = 1000;
    uint256 private constant PERCENT_MULTIPLIER = 1000; // For 0.5% transaction fee
    uint256 private constant MAX_SCORE = 100;
    uint256 private constant BASE = 10**8;
    uint256 private constant ETHER_IN_WEI = 1 ether;
    uint256 public unstakeFee = 50; // 5%
 uint256 public totalRevenueFromTransactionFees = 0; 
    uint256 public totalRevenueFromClaimFees = 0;
// Define new roles
    bytes32 public constant GAME_ADMIN_ROLE = keccak256("GAME_ADMIN_ROLE");
    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");

    // State variables
    bytes32 public jobId;
    uint256 public oraclePaymentAmount;

    uint256 public transactionFee = 5; // 0.5%
    uint256 public globalTreasury;
Counters.Counter private _totalWins;
uint256 public totalLosses;
    uint256 public totalPlayoffTeams;
    uint256 public totalEliminatedTeams;
    uint256 public playoffDemandFactor;
    uint256 public eliminationDemandFactor;
    uint256 public totalTradingVolume = 0;  // Added for gas optimization

    // Mapping from city name to CITY token ID
    mapping(string => uint256) public cityToTokenId;
    // Mapping from CITY token ID to city name
    mapping(uint256 => string) public tokenIdToCity;
    mapping(uint256 => uint256) public reserves;
    mapping(uint256 => address) public teamTreasury;
    mapping(uint256 => mapping(uint256 => GameResult)) public gameResults;
    uint256 public lastResultUpdateBlock;
    uint256 public stakingBonus = 0;  // X, undetermined staking bonus
    bool public seasonIsActive = false;
    // Event declarations
    event PriceUpdated(uint256 newPrice);
    event RevenueUpdated(uint256 newTotalRevenue);

    AggregatorV3Interface private priceFeed;
    IERC20 private immutableX;


    // Chainlink specific variables
    address private oracle;
    uint256 private fee;

struct GameResult {
    uint32 homeScore;
    uint32 awayScore;
    bool resultSubmitted;
    bool teamMadePlayoff;
    bool teamEliminated;
}

// struct to encapsulate oracle details for cleaner code
    struct OracleDetails {
        bytes32 jobId;
        uint256 fee;
        address oracleAddress;
    }

    OracleDetails public oracleDetails;

    modifier onlyOracle() {
        require(msg.sender == oracleDetails.oracleAddress, "Caller is not the oracle");
        _;
    }


    // Initialize the contract with necessary parameters
function initialize(
    address[] memory _teamTreasuryAddresses,
    string memory _uri,
    address _priceFeedAddress,
    address _immutableXAddress,
    address _rootChainManagerAddress,
    address _polygonERC1155Address,
    bytes32 _jobId,
    uint256 _oraclePaymentAmount,
    address _oracle,
    bytes32 _chainlinkJobId,
    uint256 _chainlinkFee
) public initializer {
    require(_teamTreasuryAddresses.length == TEAM_COUNT, "Invalid team treasury addresses length");
        // Initialize cityToTokenId and tokenIdToCity mappings
        // Assuming city names and token IDs are 1-indexed for simplicity
       cityToTokenId["Anaheim"] = 1; tokenIdToCity[1] = "Anaheim";
cityToTokenId["Arizona"] = 2; tokenIdToCity[2] = "Arizona";
cityToTokenId["Boston"] = 3; tokenIdToCity[3] = "Boston";
cityToTokenId["Buffalo"] = 4; tokenIdToCity[4] = "Buffalo";
cityToTokenId["Calgary"] = 5; tokenIdToCity[5] = "Calgary";
cityToTokenId["Carolina"] = 6; tokenIdToCity[6] = "Carolina";
cityToTokenId["Chicago"] = 7; tokenIdToCity[7] = "Chicago";
cityToTokenId["Colorado"] = 8; tokenIdToCity[8] = "Colorado";
cityToTokenId["Columbus"] = 9; tokenIdToCity[9] = "Columbus";
cityToTokenId["Dallas"] = 10; tokenIdToCity[10] = "Dallas";
cityToTokenId["Detroit"] = 11; tokenIdToCity[11] = "Detroit";
cityToTokenId["Edmonton"] = 12; tokenIdToCity[12] = "Edmonton";
cityToTokenId["Florida"] = 13; tokenIdToCity[13] = "Florida";
cityToTokenId["Los Angeles"] = 14; tokenIdToCity[14] = "Los Angeles";
cityToTokenId["Minnesota"] = 15; tokenIdToCity[15] = "Minnesota";
cityToTokenId["Montreal"] = 16; tokenIdToCity[16] = "Montreal";
cityToTokenId["Nashville"] = 17; tokenIdToCity[17] = "Nashville";
cityToTokenId["New Jersey"] = 18; tokenIdToCity[18] = "New Jersey";
cityToTokenId["New Island"] = 19; tokenIdToCity[19] = "New Island";
cityToTokenId["New York"] = 20; tokenIdToCity[20] = "New York";
cityToTokenId["Ottawa"] = 21; tokenIdToCity[21] = "Ottawa";
cityToTokenId["Philadelphia"] = 22; tokenIdToCity[22] = "Philadelphia";
cityToTokenId["Pittsburgh"] = 23; tokenIdToCity[23] = "Pittsburgh";
cityToTokenId["San Jose"] = 24; tokenIdToCity[24] = "San Jose";
cityToTokenId["Seattle"] = 25; tokenIdToCity[25] = "Seattle";
cityToTokenId["St. Louis"] = 26; tokenIdToCity[26] = "St. Louis";
cityToTokenId["Tampa Bay"] = 27; tokenIdToCity[27] = "Tampa Bay";
cityToTokenId["Toronto"] = 28; tokenIdToCity[28] = "Toronto";
cityToTokenId["Vancouver"] = 29; tokenIdToCity[29] = "Vancouver";
cityToTokenId["Vegas"] = 30; tokenIdToCity[30] = "Vegas";
cityToTokenId["Washington"] = 31; tokenIdToCity[31] = "Washington";
cityToTokenId["Winnipeg"] = 32; tokenIdToCity[32] = "Winnipeg";
    }
    // Initialize ERC20 and ERC1155
    ERC20.__ERC20_init("Puck City", "PUCK");
    ERC1155.__ERC1155_init(_uri);
        
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
        immutableX = IERC20(_immutableXAddress);
        rootChainManager = RootChainManager(_rootChainManagerAddress);
        polygonERC1155 = IERC1155(_polygonERC1155Address);
        jobId = _jobId;
        oraclePaymentAmount = _oraclePaymentAmount;

        // Chainlink setup
        setPublicChainlinkToken();
        oracle = _oracle;
        jobId = _chainlinkJobId;
        fee = _chainlinkFee;
    }
    // Function to purchase PUCK tokens
    function purchasePuck(uint256 amount) external payable whenNotPaused nonReentrant {
        require(msg.value >= puckPrice * amount, "Insufficient ether sent");
        _mint(msg.sender, PUCK, amount, "");
    }

    // Function to convert PUCK to CITY tokens
    function convertPuckToCity(uint256 amount, string memory cityName) external whenNotPaused nonReentrant {
        uint256 cityTokenId = cityToTokenId[cityName];
        require(cityTokenId != 0, "City not found");
        require(balanceOf(msg.sender, PUCK) >= amount, "Insufficient PUCK tokens");
        _burn(msg.sender, PUCK, amount);
        _mint(msg.sender, cityTokenId, amount, "");
    }
    // Function to withdraw from the global treasury
    function withdrawFromGlobalTreasury(uint256 _amount) public onlyOwner {
        require(_amount <= globalTreasury, "Insufficient balance in global treasury");
        globalTreasury -= _amount;
        (bool success,) = owner().call{value: _amount}("");
        require(success, "Withdrawal from global treasury failed");
    }

    // Get current price of the token
    function getCurrentPrice() public view returns (uint256) {
        uint256 reserveBalance = getReserveBalance(totalTradingVolume);
    }

    // Calculate the total trading volume
    function getTotalTradingVolume() public view returns (uint256) {
        return totalTradingVolume;
    }

    function getReserveBalance(uint256 tradingVolume) public view returns (uint256) {
        return globalTreasury - tradingVolume;
    }

    // Function to calculate the price
       function _calculatePrice(uint256 tradingVolume, uint256 reserveBalance) internal view returns (uint256) {
        uint256 totalSupplyCached = totalSupply();  // Cache totalSupply for gas optimization
        uint256 winRatio = _getWinRatio();
        uint256 reserveRatio = _getReserveRatio(reserveBalance);
        uint256 demandFactor = _getDemandFactor();
        uint256 feeFactor = _getFeeFactor();
        uint256 treasuryTransactionFactor = _getTreasuryTransactionFactor();

        uint256 price = (tradingVolume * BASE / totalSupplyCached)
                      * winRatio
                      * reserveRatio
                      * demandFactor
                      * feeFactor
                      * treasuryTransactionFactor
                      / (BASE * BASE * BASE * BASE * BASE);  // Dividing by BASE^5 to correct for the five multiplications above

        return price;
    }
    // Function to purchase tokens
/**
 * @notice Purchase tokens for a specific team.
 * @param _amount The amount of tokens to purchase.
 * @param _teamId The ID of the team for which to purchase tokens.
 */
// Function to purchase tokens
    function purchaseToken(uint256 _amount, uint256 _teamId) public payable whenNotPaused nonReentrant {
        require(_amount > 0 && _amount <= TOKENS_PER_TEAM, "Invalid amount");
        require(_teamId < TEAM_COUNT, "Invalid team ID");
        uint256 totalSupply = totalSupply();
        require(totalSupply < TEAM_COUNT * TOKENS_PER_TEAM, "All tokens have been minted");
        uint256 currentPrice = getCurrentPrice();
        uint256 totalPrice = currentPrice * _amount;
        require(msg.value >= totalPrice, "Insufficient payment");

        // Calculate the transaction fee amount
        uint256 transactionFeeAmount = (totalPrice * transactionFee) / PERCENT_MULTIPLIER;

        reserves[_teamId * TOKENS_PER_TEAM + (totalSupply % TOKENS_PER_TEAM)] += totalPrice;
        totalTradingVolume += totalPrice;  // Update the trading volume

        // Update total revenue from transaction fees
        totalRevenueFromTransactionFees += transactionFeeAmount;

        emit RevenueUpdated(totalRevenueFromTransactionFees + totalRevenueFromClaimFees);  // Emitting revenue update event

        // Transfer 0.5% of the payment to the contract owner
        uint256 transactionFeeAmount = (totalPrice * transactionFee) / PERCENT_MULTIPLIER;
        (bool transferToOwner,) = payable(owner()).call{value: transactionFeeAmount}();
        require(transferToOwner, "Transfer to contract owner failed");

        // Transfer remaining payment to global treasury
        uint256 remainingAmount = totalPrice - transactionFeeAmount;
        globalTreasury += remainingAmount;

        // Refund any excess payment
        uint256 refundAmount = msg.value - totalPrice;
        if (refundAmount > 0) {
            (bool refund,) = payable(msg.sender).call{value: refundAmount}();
            require(refund, "Refund failed");
        }

        emit TokenPurchased(msg.sender, _amount, _teamId);


        uint256 value = reserves[_teamId * TOKENS_PER_TEAM + (balance - 1)];
        require(value > 0, "Token has no value");
// Update total revenue from claim fees
        totalRevenueFromClaimFees += feeAmount;

        emit RevenueUpdated(totalRevenueFromTransactionFees + totalRevenueFromClaimFees);  
        // Emitting revenue update event

        // Deduct the unstake fee
        uint256 feeAmount = (value * unstakeFee) / PERCENT_MULTIPLIER;
        uint256 afterFeeValue = value - feeAmount;
        globalTreasury += feeAmount;

        reserves[_teamId * TOKENS_PER_TEAM + (balance - 1)] = 0;
        totalTradingVolume -= afterFeeValue;  // Update the trading volume

        bool transferFromSuccess = immutableX.transferFrom(address(this), msg.sender, afterFeeValue);
        require(transferFromSuccess, "Transfer from failed");

        _burn(msg.sender, _teamId, balance);
        emit TokenClaimed(msg.sender, balance, _teamId);
    }
    // Migrate ERC20 tokens to Polygon
    function migrateERC20ToPolygon(uint256 _amount) public onlyOwner {
        require(address(rootChainManager) != address(0), "Invalid rootChainManager address");
        rootChainManager.depositERC20(address(immutableX), msg.sender, _amount);
    }

    // Setter functions for contract parameters
    function setOraclePaymentAmount(uint256 _oraclePaymentAmount) public onlyOwner {
        oraclePaymentAmount = _oraclePaymentAmount;
    }

    function setJobId(bytes32 _jobId) public onlyOwner {
        jobId = _jobId;
    }

    function setTransactionFee(uint256 _transactionFee) public onlyOwner {
        transactionFee = _transactionFee;
    }

    function setStakingBonus(uint256 _stakingBonus) public onlyOwner {
        stakingBonus = _stakingBonus;
    }

    function setSeasonStatus(bool _isActive) public onlyOwner {
        seasonIsActive = _isActive;
    }

    function setPlayoffDemandFactor(uint256 _playoffDemandFactor) public onlyOwner {
        playoffDemandFactor = _playoffDemandFactor;
    }

    function setEliminationDemandFactor(uint256 _eliminationDemandFactor) public onlyOwner {
        eliminationDemandFactor = _eliminationDemandFactor;
    }
// Function to claim tokens
    function claimToken(uint256 _teamId) public nonReentrant whenNotPaused {
    require(_teamId < TEAM_COUNT, "Invalid team ID");
    uint256 balance = balanceOf(msg.sender, _teamId);
    require(balance > 0, "No tokens to claim");

    uint256 value = reserves[_teamId * TOKENS_PER_TEAM + (balance - 1)];
    require(value > 0, "Token has no value");

    // Deduct the unstake fee
    uint256 feeAmount = (value * unstakeFee) / PERCENT_MULTIPLIER;
    uint256 afterFeeValue = value - feeAmount;
    globalTreasury += feeAmount;

    // Update total revenue from claim fees
    totalRevenueFromClaimFees += feeAmount;
    emit RevenueUpdated(totalRevenueFromTransactionFees + totalRevenueFromClaimFees);  // Emitting revenue update event

    reserves[_teamId * TOKENS_PER_TEAM + (balance - 1)] = 0;
    totalTradingVolume -= afterFeeValue;  // Update the trading volume

    bool transferFromSuccess = immutableX.transferFrom(address(this), msg.sender, afterFeeValue);
    require(transferFromSuccess, "Transfer from failed");

    _burn(msg.sender, _teamId, balance);
    emit TokenClaimed(msg.sender, balance, _teamId);
}

    // Function to set game results
    function setGameResult(uint256 _teamId, uint256 _gameId, uint256 _homeScore, uint256 _awayScore, bool _teamMadePlayoff, bool _teamEliminated) public onlyRole(GAME_ADMIN_ROLE) {

        require(_teamId < TEAM_COUNT, "Invalid team ID");
        require(!gameResults[_teamId][_gameId].resultSubmitted, "Result already submitted");

        gameResults[_teamId][_gameId] = GameResult({
            homeScore: _homeScore,
            awayScore: _awayScore,
            resultSubmitted: true,
            teamMadePlayoff: _teamMadePlayoff,
            teamEliminated: _teamEliminated
        });

        if (_homeScore > _awayScore) {
            _totalWins.increment();
        } else {
            totalLosses++;
        }

        if (_teamMadePlayoff) {
            totalPlayoffTeams++;
        }

        if (_teamEliminated) {
            totalEliminatedTeams++;
        }

        lastResultUpdateBlock = block.number;
        emit GameResultUpdated(_teamId, _gameId, _homeScore, _awayScore);
    }
// Helper function to get win ratio: W / (W + L)
    function _getWinRatio() internal view returns (uint256) {
        return (totalWins * BASE * BASE) / (totalWins + totalLosses);
    }

    // Helper function to get reserve ratio: R / C
    function _getReserveRatio(uint256 reserveBalance) internal pure returns (uint256) {
        return (reserveBalance * BASE) / TEAM_COUNT;
    }

    // Helper function to get demand factor: 1 + F * S / C - G * E / C
    function _getDemandFactor() internal view returns (uint256) {
        return BASE + playoffDemandFactor * totalPlayoffTeams * BASE / TEAM_COUNT - eliminationDemandFactor * totalEliminatedTeams * BASE / TEAM_COUNT;
    }

    // Helper function to get fee factor: 1 + TF * TR / T + CF * CR / T
    function _getFeeFactor() internal view returns (uint256) {
        return BASE + transactionFee * totalRevenueFromTransactionFees * BASE / totalSupply() + unstakeFee * totalRevenueFromClaimFees * BASE / totalSupply();
    }

    // Helper function to get treasury transaction factor: 1 + TF * Tm / Gm
    function _getTreasuryTransactionFactor() internal pure returns (uint256) {
        uint256 Tm = GAMES_IN_SEASON * TEAM_COUNT;  // Assuming playoffs operate in a separate contract for simplification
        return BASE + transactionFee * Tm * BASE / GAMES_IN_SEASON;
    }

    // Main function to calculate price based on formula: P = (V / T) * (W / (W + L)) * (R / C) * (1 + F * S / C - G * E / C) * (1 + TF * TR / T + CF * CR / T) * (1 + TF * Tm / Gm)
     function _calculatePrice(uint256 tradingVolume, uint256 reserveBalance) internal view returns (uint256) {
        uint256 totalSupplyCached = totalSupply();  // Cache totalSupply for gas optimization
        uint256 winRatio = _getWinRatio();
        uint256 reserveRatio = _getReserveRatio(reserveBalance);
        uint256 demandFactor = _getDemandFactor();
        uint256 feeFactor = _getFeeFactor();
        uint256 treasuryTransactionFactor = _getTreasuryTransactionFactor();

        uint256 price = (tradingVolume * BASE / totalSupply())
                      * winRatio
                      * reserveRatio
                      * demandFactor
                      * feeFactor
                      * treasuryTransactionFactor
                      / (BASE * BASE * BASE * BASE * BASE);  // Dividing by BASE^5 to correct for the five multiplications above

        return price;
    }
// Update token price
        uint256 newPrice = _calculatePrice(totalTradingVolume, globalTreasury - totalTradingVolume);
        emit PriceUpdated(newPrice);  // Emitting price update event
    }
    // Chainlink function to request game results
    function requestGameResult(uint256 _teamId, uint256 _gameId) public onlyOwner returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL and path for the sportsdata.io NHL API (this is just a placeholder and might need to be adjusted)
        request.add("get", "https://api.sportsdata.io/v4/nhl/scores/json/GamesByDate/2023-09-01");
        request.add("path", "Teams[0].Score");  // Adjust the path to get the desired data

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    // Function to handle Chainlink responses
function fulfill(bytes32 _requestId, uint256 _teamId, uint256 _gameId, uint256 _score) public onlyOracle recordChainlinkFulfillment(_requestId) {
        gameResults[_teamId][_gameId].homeScore = _score;
    }

    // Functions to control contract state
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Override function to add custom logic
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    function lockTokens(uint256[] memory _ids, uint256[] memory _amounts) external onlyRole(BRIDGE_ROLE) {
        require(_ids.length == _amounts.length, "Mismatched ids and amounts arrays");
        
        for (uint i = 0; i < _ids.length; i++) {
            // Transfer tokens to the PoS bridge contract
            safeTransferFrom(msg.sender, address(rootChainManager), _ids[i], _amounts[i], "");
        }

        // Notify the PoS bridge
        // This would typically involve interacting with the PoS bridge contract
    }

    function unlockTokens(address _user, uint256[] memory _ids, uint256[] memory _amounts) external onlyRole(BRIDGE_ROLE) {

        require(_ids.length == _amounts.length, "Mismatched ids and amounts arrays");

        for (uint i = 0; i < _ids.length; i++) {
            // This function would typically be called by the PoS bridge,
            // which would hold the tokens until they're unlocked
            safeTransferFrom(address(this), _user, _ids[i], _amounts[i], "");
        }
    }

    modifier onlyBridge() {
        require(msg.sender == address(rootChainManager), "Not authorized");
        _;
    }
}
