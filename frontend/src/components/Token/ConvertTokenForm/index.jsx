import React, { useState } from 'react';
import { contractService } from '../../../services/contractService';
import './styles.css';

function ConvertTokenForm() {
  const [amount, setAmount] = useState('');
  const [cityName, setCityName] = useState('');

  const handleConvert = async () => {
    try {
      await contractService.convertPuckToCity(amount, cityName);
      alert('Conversion successful');
    } catch (error) {
      console.error(error);
      alert('Conversion failed');
    }
  };

  return (
    <div>
      <input
        type="number"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="Amount"
      />
      <input
        type="text"
        value={cityName}
        onChange={(e) => setCityName(e.target.value)}
        placeholder="City Name"
      />
      <button onClick={handleConvert}>Convert to CITY</button>
    </div>
  );
}

export default ConvertTokenForm;
