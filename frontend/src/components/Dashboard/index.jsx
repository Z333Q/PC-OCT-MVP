import React, { useState, useEffect } from 'react';
import web3 from '../../utils/web3';
import contractService from '../../services/contractService';
import './styles.css';

const Dashboard = () => {
  const [account, setAccount] = useState('');
  const [balance, setBalance] = useState(0);

  useEffect(() => {
    const init = async () => {
      const accounts = await web3.eth.getAccounts();
      setAccount(accounts[0]);
      const balance = await contractService.getBalance(accounts[0]);
      setBalance(web3.utils.fromWei(balance, 'ether'));
    };
    init();
  }, []);

  return (
    <div className="dashboard-container">
      <h2>Dashboard</h2>
      <div className="dashboard-info">
        <p>Account: {account}</p>
        <p>Balance: {balance} ETH</p>
      </div>
    </div>
  );
};

export default Dashboard;
