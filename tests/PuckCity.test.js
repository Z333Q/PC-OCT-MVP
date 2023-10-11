const { expect } = require("chai");

describe("Puck City", function () {
    let PuckCity, puckCity, owner, addr1, addr2;
    
    beforeEach(async () => {
        PuckCity = await ethers.getContractFactory("PuckCity");
        puckCity = await PuckCity.deploy();
        await puckCity.deployed();
        
        [owner, addr1, addr2, _] = await ethers.getSigners();
    });
    
    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await puckCity.owner()).to.equal(owner.address);
        });
        
        // ... other tests
    });
    
    // ... other describe blocks
});
