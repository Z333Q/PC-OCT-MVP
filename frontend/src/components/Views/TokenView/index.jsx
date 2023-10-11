import React, { useEffect, useState } from 'react';
import contractService from '../../../../services/contractService';
import './styles.css';

const TokenView = () => {
  const [tokenBalance, setTokenBalance] = useState(null);

  useEffect(() => {
    const fetchTokenBalance = async () => {
      const balance = await contractService.getTokenBalance();
      setTokenBalance(balance);
    };
    
    fetchTokenBalance();
  }, []);

  return (
    <div className="token-view">
      <h2>Your Token Balance: {tokenBalance}</h2>
    </div>
  );
};

export default TokenView;
