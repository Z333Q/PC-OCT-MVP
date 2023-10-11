// src/components/Admin/AdminSettingsForm/index.jsx

import React, { useState } from 'react';
import contractServices from '../../../../services/contractService';
import './styles.css';

const AdminSettingsForm = () => {
  const [transactionFee, setTransactionFee] = useState('');
  // ... Other state variables for other parameters

  const handleUpdateParameters = async () => {
    try {
      await contractServices.setTransactionFee(transactionFee);
      // ... Other contract method calls to set other parameters
      setMessage('Parameters updated successfully');
    } catch (error) {
      console.error(error);
      setMessage('Failed to update parameters');
    }
  };

  return (
    <div>
      <h2>Admin Settings</h2>
      <input
        type="text"
        placeholder="Transaction Fee"
        value={transactionFee}
        onChange={(e) => setTransactionFee(e.target.value)}
      />
      {/* ... Other input fields for other parameters */}
      <button onClick={handleUpdateParameters}>Update Parameters</button>
      {message && <div>{message}</div>}
    </div>
  );
};

export default AdminSettingsForm;
