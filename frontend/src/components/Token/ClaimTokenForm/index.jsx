// File: frontend/src/components/Token/ClaimTokenForm/index.jsx

import React, { useState } from 'react';
import { contractService } from '../../../services/contractService';
import './styles.css';  // Importing styles

function ClaimTokenForm() {
  const [teamId, setTeamId] = useState('');

  const handleClaim = async () => {
    try {
      await contractService.claimToken(parseInt(teamId, 10));  // Parse string to integer
      alert('Claim successful');
    } catch (error) {
      console.error(error);
      alert('Claim failed');
    }
  };

  return (
    <div className="claim-token-form">  {/* Adjusted className */}
      <input
        type="number"
        value={teamId}
        onChange={(e) => setTeamId(e.target.value)}
        placeholder="Team ID"
      />
      <button onClick={handleClaim}>Claim PUCK</button>
    </div>
  );
}

export default ClaimTokenForm;

