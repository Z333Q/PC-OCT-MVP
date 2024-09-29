
const hre = require('hardhat');

async function main() {
    const PuckCity = await hre.ethers.getContractFactory('PuckCity');
    const puckCity = await PuckCity.deploy();
    await puckCity.deployed();

    console.log('Puck City deployed to:', puckCity.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

// Function to get the treasury balance of a team
export const getTeamTreasury = async (teamId) => {
    const treasury = await contract.teamTreasury(teamId);
    return ethers.utils.formatEther(treasury);
};

// Function to finalize game result and transfer treasury
export const finalizeGame = async (homeTeamId, awayTeamId, homeScore, awayScore) => {
    const tx = await contract.finalizeGame(homeTeamId, awayTeamId, homeScore, awayScore);
    await tx.wait();
    console.log('Game finalized and treasury updated.');
};
