// src/components/Admin/GameAdmin.jsx

import React, { useState } from 'react';
import contractServices from '../../../services/contractService';

const GameAdmin = () => {
  const [teamId, setTeamId] = useState('');
  const [gameId, setGameId] = useState('');
  const [homeScore, setHomeScore] = useState('');
  const [awayScore, setAwayScore] = useState('');
  const [message, setMessage] = useState('');

  const handleSetGameResult = async () => {
    try {
      await contractServices.setGameResult(teamId, gameId, homeScore, awayScore);
      setMessage('Game result updated successfully');
    } catch (error) {
      console.error(error);
      setMessage('Failed to update game result');
    }
  };

  return (
    <div>
      <h2>Game Administration</h2>
      <input
        type="text"
        placeholder="Team ID"
        value={teamId}
        onChange={(e) => setTeamId(e.target.value)}
      />
      <input
        type="text"
        placeholder="Game ID"
        value={gameId}
        onChange={(e) => setGameId(e.target.value)}
      />
      <input
        type="text"
        placeholder="Home Score"
        value={homeScore}
        onChange={(e) => setHomeScore(e.target.value)}
      />
      <input
        type="text"
        placeholder="Away Score"
        value={awayScore}
        onChange={(e) => setAwayScore(e.target.value)}
      />
      <button onClick={handleSetGameResult}>Set Game Result</button>
      {message && <div>{message}</div>}
    </div>
  );
};

export default GameAdmin;
