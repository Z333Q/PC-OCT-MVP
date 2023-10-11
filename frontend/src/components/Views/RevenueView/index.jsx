import React, { useEffect, useState } from 'react';
import contractService from '../../../../services/contractService';
import './styles.css';

const RevenueView = () => {
  const [revenue, setRevenue] = useState(null);

  useEffect(() => {
    const fetchRevenue = async () => {
      const currentRevenue = await contractService.getRevenue();
      setRevenue(currentRevenue);
    };
    
    fetchRevenue();
  }, []);

  return (
    <div className="revenue-view">
      <h2>Total Revenue: {revenue}</h2>
    </div>
  );
};

export default RevenueView;
