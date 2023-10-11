import Web3 from 'web3';
import PuckCityContract from '../../contracts/PuckCity.json';

let web3;
let contract;

const initializeWeb3 = async () => {
  if (window.ethereum) {
    web3 = new Web3(window.ethereum);
    await window.ethereum.enable();
  } else if (window.web3) {
    web3 = new Web3(window.web3.currentProvider);
  } else {
    window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!');
  }
};

const initializeContract = async () => {
  const networkId = await web3.eth.net.getId();
  const networkData = PuckCityContract.networks[networkId];
  
  if (networkData) {
    const abi = PuckCityContract.abi;
    const address = networkData.address;
    contract = new web3.eth.Contract(abi, address);
  } else {
    window.alert('Smart contract not deployed to the detected network.');
  }
};

const purchasePuck = async (amount) => {
  await initializeWeb3();
  await initializeContract();
  const accounts = await web3.eth.getAccounts();
  await contract.methods.purchasePuck(amount).send({ from: accounts[0], value: web3.utils.toWei(amount.toString(), 'ether') });
};

const convertPuckToCity = async (amount, cityName) => {
  await initializeWeb3();
  await initializeContract();
  const accounts = await web3.eth.getAccounts();
  await contract.methods.convertPuckToCity(amount, cityName).send({ from: accounts[0] });
};

const claimToken = async (teamId) => {
  await initializeWeb3();
  await initializeContract();
  const accounts = await web3.eth.getAccounts();
  await contract.methods.claimToken(teamId).send({ from: accounts[0] });
};

const withdrawFromTreasury = async (amount) => {
  await initializeWeb3();
  await initializeContract();
  const accounts = await web3.eth.getAccounts();
  await contract.methods.withdrawFromGlobalTreasury(web3.utils.toWei(amount.toString(), 'ether')).send({ from: accounts[0] });
};

const getCurrentPrice = async () => {
  await initializeWeb3();
  await initializeContract();
  const price = await contract.methods.getCurrentPrice().call();
  return web3.utils.fromWei(price, 'ether');
};

const getRevenue = async () => {
  await initializeWeb3();
  await initializeContract();
  const totalRevenueFromTransactionFees = await contract.methods.totalRevenueFromTransactionFees().call();
  const totalRevenueFromClaimFees = await contract.methods.totalRevenueFromClaimFees().call();
  return {
    totalRevenueFromTransactionFees: web3.utils.fromWei(totalRevenueFromTransactionFees, 'ether'),
    totalRevenueFromClaimFees: web3.utils.fromWei(totalRevenueFromClaimFees, 'ether'),
  };
};

export default {
  purchasePuck,
  convertPuckToCity,
  claimToken,
  withdrawFromTreasury,
  getCurrentPrice,
  getRevenue,
};
