import Web3 from 'web3';

// Assuming Metamask is installed or the user's browser is Ethereum enabled
let web3;

if (window.ethereum) {
    // Request account access if needed
    window.ethereum.enable().then(function() {
        // User has allowed account access to DApp...
    });
    web3 = new Web3(window.ethereum);
} else if (window.web3) {
    // Legacy DApp Browsers
    web3 = new Web3(window.web3.currentProvider);
} else {
    // Non-DApp Browsers
    alert('You have to install MetaMask !');
}

export default web3;