import React, { useState } from 'react';
import contractService from '../../../services/contractService';
import './styles.css';

const RequestGameResultForm = () => {
  const [teamId, setTeamId] = useState('');

  const handleResultRequest = async () => {
    if (teamId) {
      await contractService.requestGameResult(teamId);
    }
  };

  return (
    <div className="request-game-result-form">
      <h2>Request Game Result</h2>
      <input
        type="number"
        placeholder="Team ID"
        value={teamId}
        onChange={(e) => setTeamId(e.target.value)}
      />
      <button onClick={handleResultRequest}>Request</button>
    </div>
  );
};

export default RequestGameResultForm;
