import { useEffect,useState } from 'react';
import React from 'react';
import './styles/App.css';
import staking from "./artifacts/contracts/Staking_Contract.sol/Stacking.json";
import prime from "./artifacts/contracts/Prime.sol/Prime.json";
import {ethers} from "ethers";
// Constants
const STAKING_ADDRESS = "0x2F569d2F808976aBFf3cBbaC7070042d5916B08B";
const PRIME_ADDRESS = "0xB5CEeeb0f3B7F6B47D1dADaBF6a4cF67e8e18fc8"



const App = () => {

  const [currentAccount, setCurrentAccount] = useState('');
  const [toAccount,setToAccount] = useState('');
  const [mintAmount,setAmount] = useState('');
  const [stakAmount,setStakAmount] = useState('');
  const [primeAmount,setPrimeAmount] = useState('');

  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask -> https://metamask.io/");
        return;
      }

      // Fancy method to request access to account.
      const accounts = await ethereum.request({ method: "eth_requestAccounts" });
    
      // Boom! This should print out public address once we authorize Metamask.
      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]);
     
     
     
      
     
    } catch (error) {
      console.log(error)
    }
  }
  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log('Make sure you have metamask!');
      return;
    } else {
      console.log('We have the ethereum object', ethereum);
    }

    const accounts = await ethereum.request({ method: 'eth_accounts' });

    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log('Found an authorized account:', account);
      setCurrentAccount(account);
    } else {
      console.log('No authorized account found');
    }
  };

  const minttoken = async() =>{
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(STAKING_ADDRESS, staking.abi, signer);
        const txn = await contract.mintToken(toAccount,mintAmount);
        await txn.wait();
        getDetials(currentAccount);
     }
   }catch(error){
    console.log(error)
   
   }

}

  const stake = async() =>{
    try{
      const {ethereum} = window;
      if(ethereum){
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(STAKING_ADDRESS, staking.abi, signer);
       
        const txn = await contract.stak(stakAmount);
        await txn.wait();
        getDetials(currentAccount);
      }
    }catch(error){
      console.log(error);
    }
  }
  async function getDetials(account) {
    
    try{
      const {ethereum} = window;
      if(ethereum){
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const contract1 = new ethers.Contract(STAKING_ADDRESS, staking.abi, signer);
        const poolDetails = await contract1.currentPool();
        console.log("Current Pool Details ",poolDetails.toString());
        const poolId = await contract1.poolId();
        console.log("Current Pool Id ",poolId.toString());
        const erc20Balance = await contract1.balanceOf(account);
        console.log("ERC20 token balance ",erc20Balance.toString())
        const contract2 = new ethers.Contract(PRIME_ADDRESS, prime.abi, signer);
        const primeBalance = await contract2.balanceOf(account);
        console.log("Prime Balance ",primeBalance.toString());
        console.log("Current Account ",currentAccount);

      }
    }catch(error){
      console.log(error);
    }
}

  const claim = async() =>{
    try{
      const {ethereum} = window;
      if(ethereum){
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(STAKING_ADDRESS, staking.abi, signer);
        const txn = await contract.claim(currentAccount);
        await txn.wait();
        getDetials(currentAccount);
      }
    }catch(error){
      console.log(error);
    }
  }

  const transfer = async() =>{
    try{
      const {ethereum} = window;
      if(ethereum){
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(PRIME_ADDRESS ,prime.abi, signer);
        const txn = await contract.transfer(STAKING_ADDRESS,primeAmount);
        await txn.wait();
        
      }
    }catch(error){
      console.log(error);
    }
  }

  const unStake = async() =>{
    try{
      const {ethereum} = window;
      if(ethereum){
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(STAKING_ADDRESS, staking.abi, signer);
        const txn = await contract.unstake(currentAccount);
        await txn.wait();
        getDetials(currentAccount);
      }
    }catch(error){
      console.log(error);
    }
  }


  // Create a function to render if wallet is not connected yet

  const renderInputForm = () =>{
		return (
			<div className="form-container">
				<div className="first-row">
					<input
						type="text"
						
						placeholder='toAddress'
						onChange={e => setToAccount(e.target.value)}
					/>
					
				</div>

				<input
					type="text"
				
					placeholder='amount'
					onChange={e => setAmount(e.target.value)}
				/>
        <div className="button-container">
					<button className='cta-button mint-button' disabled={null} onClick={minttoken}>
						Mint
					</button> 
          </div>

        <input
					type="text"
					
					placeholder='stakAmount'
					onChange={e => setStakAmount(e.target.value)}
				/>

				<div className="button-container">
				
          <button className='cta-button mint-button' disabled={null} onClick={stake}>
						Stake
					</button> 
          <button className='cta-button mint-button' disabled={null} onClick={claim}>
						Claim
					</button>  
          <button className='cta-button mint-button' disabled={null} onClick={unStake}>
          Unstake
          
					</button> 
          <br/> 
          <input
					type="text"
					
					placeholder='primeAmount'
					onChange={e => setPrimeAmount(e.target.value)}
				/>
         <button className='cta-button mint-button' disabled={null} onClick={transfer}>
          Transfer_Prime
					</button>
				 
				</div>

			</div>
		);
	}
  const renderNotConnectedContainer = () => (
    <div className="connect-wallet-container">
      <img src="https://media.giphy.com/media/3ohhwytHcusSCXXOUg/giphy.gif" alt="Ninja donut gif" />
      {/* Call the connectWallet function we just wrote when the button is clicked */}
      <button onClick={connectWallet} className="cta-button connect-wallet-button">
        Connect Wallet
      </button>
    </div>
  );

    useEffect(() => {
      checkIfWalletIsConnected();
    }, []);
  
  return (
		<div className="App">
			<div className="container">

				<div className="header-container">
					<header>
            <div className="left">
              <p className="title">🐱‍👤 Staking Contract</p>
              <p className="subtitle">Stake your ERC20 token and earn Prime token</p>
            </div>
					</header>
				</div>
        {!currentAccount && renderNotConnectedContainer()}
				{/* Render the input form if an account is connected */}
				{currentAccount && renderInputForm()}

       
			</div>
		</div>
	);
}

export default App;
