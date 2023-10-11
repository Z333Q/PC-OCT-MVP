import React, { useEffect, useState } from 'react';
import contractService from '../../../../services/contractService';
import './styles.css';

const PriceView = () => {
  const [price, setPrice] = useState(null);

  useEffect(() => {
    const fetchPrice = async () => {
      const currentPrice = await contractService.getCurrentPrice();
      setPrice(currentPrice);
    };
    
    fetchPrice();
  }, []);

  return (
    <div className="price-view">
      <h2>Current Price: {price}</h2>
    </div>
  );
};

export default PriceView;
