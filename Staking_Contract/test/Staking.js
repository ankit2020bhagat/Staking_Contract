const {ethers} = require("hardhat")

describe("Staking Contract",function(){
    let accounts,staking,prime
    it ("Contract Deployment ",async function(){
        let timeToDouble = 60;
        let poolLength = 100;
        let firstPoolStartIn = 20;

        [...accounts] = await ethers.getSigners();
        const tokenFactory = await ethers.getContractFactory("Prime");
        prime = await tokenFactory.deploy(100000);
        await prime.deployed();
        console.log("Prime token deployed at :",prime.address);
        const contractFactory = await ethers.getContractFactory("Stacking");
        const staking = await contractFactory.deploy(timeToDouble,poolLength,firstPoolStartIn,prime.address);
        await staking.deployed();
        console.log("Staking Deployed at ",staking.address);
        const txn = await prime.transfer(staking.address,1000);
            await txn.wait();
        balance(staking.address)
    })

    const balance = async(account) =>{
        const primeBalance = await prime.balanceOf(account);
        console.log("Prime Balacne is ",primeBalance.toString());
        const erc20Balance  =  await staking.balanceOf(account);
        console.log("Erc 20 token Balance ",erc20Balance.toString());
    }

    describe("Mint a new Token",function(){
        it("should  transfer prime token",async function(){
            const txn = await staking.mint(accounts[1].address,1000);
            await txn.wait();
           
        })
    })
})