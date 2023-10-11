import React, { useState } from 'react';
import contractService from '../../../services/contractService';
import './styles.css';

const MigrateTokensForm = () => {
  const [amount, setAmount] = useState('');

  const handleMigration = async () => {
    if (amount) {
      await contractService.migrateTokens(amount);
    }
  };

  return (
    <div className="migrate-tokens-form">
      <h2>Migrate Tokens</h2>
      <input
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
      />
      <button onClick={handleMigration}>Migrate</button>
    </div>
  );
};

export default MigrateTokensForm;
