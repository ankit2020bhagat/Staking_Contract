const hre = require("hardhat");
const { verify } = require("../utils/verify")
async function main() {
  let timeToDouble = 20;
        let poolLength =60 ;
        let firstPoolStartIn = 10;

        [...accounts] = await ethers.getSigners();
        const tokenFactory = await ethers.getContractFactory("Prime");
        prime = await tokenFactory.deploy(100000);
        await prime.deployed();
       
        
        await prime.deployTransaction.wait(5);
        await verify(prime.address,[100000]);
        console.log("Prime token deployed at :",prime.address);
        const contractFactory = await ethers.getContractFactory("Stacking");
        const staking = await contractFactory.deploy(timeToDouble,poolLength,firstPoolStartIn,prime.address);
        await staking.deployed();
        console.log("Staking Deployed at ",staking.address);
        const txn = await prime.transfer(staking.address,1000);
        await txn.wait();
        await staking.deployTransaction.wait(5);
        await verify(staking.address,[timeToDouble,poolLength,firstPoolStartIn,prime.address])

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
