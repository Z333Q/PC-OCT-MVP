// src/components/Admin/OracleSetup.jsx

import React, { useState } from 'react';
import contractServices from '../../../services/contractService';

const OracleSetup = () => {
  const [jobId, setJobId] = useState('');
  const [oraclePaymentAmount, setOraclePaymentAmount] = useState('');
  const [message, setMessage] = useState('');

  const handleInitializeOracle = async () => {
    try {
      await contractServices.initializeOracle(jobId, oraclePaymentAmount);
      setMessage('Oracle initialized successfully');
    } catch (error) {
      console.error(error);
      setMessage('Failed to initialize oracle');
    }
  };

  return (
    <div>
      <h2>Oracle Setup</h2>
      <input
        type="text"
        placeholder="Job ID"
        value={jobId}
        onChange={(e) => setJobId(e.target.value)}
      />
      <input
        type="text"
        placeholder="Oracle Payment Amount"
        value={oraclePaymentAmount}
        onChange={(e) => setOraclePaymentAmount(e.target.value)}
      />
      <button onClick={handleInitializeOracle}>Initialize Oracle</button>
      {message && <div>{message}</div>}
    </div>
  );
};

export default OracleSetup;
