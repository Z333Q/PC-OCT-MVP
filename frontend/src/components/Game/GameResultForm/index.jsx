import React, { useState } from 'react';
import contractService from '../../../services/contractService';
import './styles.css';

const GameResultForm = () => {
  const [teamId, setTeamId] = useState('');
  const [result, setResult] = useState('');

  const handleResultSubmission = async () => {
    if (teamId && result) {
      await contractService.submitGameResult(teamId, result);
    }
  };

  return (
    <div className="game-result-form">
      <h2>Submit Game Result</h2>
      <input
        type="number"
        placeholder="Team ID"
        value={teamId}
        onChange={(e) => setTeamId(e.target.value)}
      />
      <input
        type="text"
        placeholder="Result"
        value={result}
        onChange={(e) => setResult(e.target.value)}
      />
      <button onClick={handleResultSubmission}>Submit</button>
    </div>
  );
};

export default GameResultForm;
