// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract GameManagement is AccessControl {
    bytes32 public constant GAME_ADMIN_ROLE = keccak256("GAME_ADMIN_ROLE");

    uint256 private constant TEAM_COUNT = 32;
    uint256 private constant MAX_SCORE = 100;

    struct GameResult {
        uint32 homeScore;
        uint32 awayScore;
        bool resultSubmitted;
        bool teamMadePlayoff;
        bool teamEliminated;
    }

    mapping(uint256 => mapping(uint256 => GameResult)) public gameResults;

    event GameResultUpdated(uint256 indexed teamId, uint256 indexed gameId, uint32 homeScore, uint32 awayScore);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setGameResult(
        uint256 _teamId,
        uint256 _gameId,
        uint32 _homeScore,
        uint32 _awayScore,
        bool _teamMadePlayoff,
        bool _teamEliminated
    ) public onlyRole(GAME_ADMIN_ROLE) {
        require(_homeScore <= MAX_SCORE && _awayScore <= MAX_SCORE, "Invalid scores");
        GameResult memory newResult = GameResult({
            homeScore: _homeScore,
            awayScore: _awayScore,
            resultSubmitted: true,
            teamMadePlayoff: _teamMadePlayoff,
            teamEliminated: _teamEliminated
        });
        gameResults[_teamId][_gameId] = newResult;
        emit GameResultUpdated(_teamId, _gameId, _homeScore, _awayScore);
    }
}
