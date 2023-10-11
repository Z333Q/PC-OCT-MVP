import React, { useState } from 'react';
import contractService from '../../../services/contractService';
import './styles.css';

const TreasuryWithdrawForm = () => {
  const [amount, setAmount] = useState('');

  const handleWithdrawal = async () => {
    if (amount) {
      await contractService.withdrawFromTreasury(amount);
    }
  };

  return (
    <div className="treasury-withdraw-form">
      <h2>Withdraw From Treasury</h2>
      <input
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
      />
      <button onClick={handleWithdrawal}>Withdraw</button>
    </div>
  );
};

export default TreasuryWithdrawForm;
