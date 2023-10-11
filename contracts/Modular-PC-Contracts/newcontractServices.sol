import Web3 from 'web3';
import PuckCityContract from '../../contracts/PuckCity.json';
import TreasuryManagementContract from '../../contracts/TreasuryManagement.json';
import PriceCalculationContract from '../../contracts/PriceCalculation.json';
import AccessControlManagerContract from '../../contracts/AccessControlManager.json';
import BridgeOperationsContract from '../../contracts/BridgeOperations.json';
import GameManagementContract from '../../contracts/GameManagement.json';


let web3;
let puckCityContract;
let treasuryManagementContract;
let priceCalculationContract;
// ... other contract instances

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

const initializeContracts = async () => {
  const networkId = await web3.eth.net.getId();
  
  // Initialize PuckCity contract
  const puckCityNetworkData = PuckCityContract.networks[networkId];
  if (puckCityNetworkData) {
    const abi = PuckCityContract.abi;
    const address = puckCityNetworkData.address;
    puckCityContract = new web3.eth.Contract(abi, address);
  } else {
    window.alert('PuckCity contract not deployed to the detected network.');
  }

  // Initialize TreasuryManagement contract
  const treasuryManagementNetworkData = TreasuryManagementContract.networks[networkId];
  if (treasuryManagementNetworkData) {
    const abi = TreasuryManagementContract.abi;
    const address = treasuryManagementNetworkData.address;
    treasuryManagementContract = new web3.eth.Contract(abi, address);
  } else {
    window.alert('TreasuryManagement contract not deployed to the detected network.');
  }

  // ... Initialize other contracts
};

const purchasePuck = async (amount) => {
  await initializeWeb3();
  await initializeContracts();
  const accounts = await web3.eth.getAccounts();
  await puckCityContract.methods.purchasePuck(amount).send({ from: accounts[0], value: web3.utils.toWei(amount.toString(), 'ether') });
};

const withdrawFromTreasury = async (amount) => {
  await initializeWeb3();
  await initializeContracts();
  const accounts = await web3.eth.getAccounts();
  await treasuryManagementContract.methods.withdrawFromGlobalTreasury(web3.utils.toWei(amount.toString(), 'ether')).send({ from: accounts[0] });
};

const getCurrentPrice = async () => {
  await initializeWeb3();
  await initializeContracts();
  const price = await priceCalculationContract.methods.getCurrentPrice().call();
  return web3.utils.fromWei(price, 'ether');
};

// ... other functions

export default {
  purchasePuck,
  withdrawFromTreasury,
  getCurrentPrice,
  // ... other exported functions
};