const hre = require("hardhat");

async function main() {
    const PuckCity = await hre.ethers.getContractFactory("PuckCity");
    const puckCity = await PuckCity.deploy();
    await puckCity.deployed();

    console.log("Puck City deployed to:", puckCity.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
