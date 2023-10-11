import React, { useState, useEffect } from 'react';
import { contractService } from '../../../services/contractService';

function PurchaseTokenForm() {
  const [amount, setAmount] = useState('');
  const [cityPrice, setCityPrice] = useState(0);
  const [puckPrice, setPuckPrice] = useState(0);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Fetch the prices when the component mounts
    fetchPrices();
  }, []);

  const fetchPrices = async () => {
    try {
      const cityPrice = await contractService.getCityPrice();
      const puckPrice = await contractService.getPuckPrice();
      setCityPrice(cityPrice);
      setPuckPrice(puckPrice);
    } catch (error) {
      console.error('Failed to fetch prices', error);
    }
  };

  const handlePurchase = async () => {
    try {
      setError(null);  // Reset any previous error
      await contractService.purchasePuck(amount);
      alert('Purchase successful');
    } catch (error) {
      console.error(error);
      setError('Purchase failed');
    }
  };

  return (
    <div>
      <h2>Purchase Tokens</h2>
      <div className="prices">
        <div>Price of CITY Token: {cityPrice}</div>
        <div>Price of PUCK Token: {puckPrice}</div>
      </div>
      <input
        type="number"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="Amount"
      />
      <button onClick={handlePurchase}>Purchase PUCK</button>
      {error && <div className="error">{error}</div>}
    </div>
  );
}

export default PurchaseTokenForm;

