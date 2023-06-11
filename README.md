Stacking Contract
This Solidity smart contract implements a stacking mechanism for the "MYToken" (MT) ERC20 token. It allows users to stake their tokens, earn rewards, and claim those rewards at specific pool intervals.

Features
Users can stake their MT tokens into the contract.
Staked tokens contribute to the total contract weight, which determines the distribution of rewards.
The contract operates in pools, each with a specified start and end time.
At the end of each pool, rewards are distributed based on the user's stake weight.
Users can claim their earned rewards at any time.
The contract supports multiple users and keeps track of their stake details.
Dependencies
The contract relies on the following external libraries:

OpenZeppelin: A library for secure smart contract development.
ERC20: Implements the ERC20 token standard.
SafeERC20: Provides safe methods for interacting with ERC20 tokens.
ReentrancyGuard: Prevents reentrant attacks.
Usage
Deploy the contract with the following parameters:

_timeToDouble: The time it takes for the contract's weight to double.
_poolLength: The duration of each pool in seconds.
_firstPoolStartIn: The delay before the first pool starts in seconds.
_prime: The address of the MYToken (MT) contract.
Mint MT tokens to the contract using the mint function. This will increase the total supply of MT tokens.

Users can stake their MT tokens by calling the stack function and specifying the desired amount. This will transfer the tokens from the user to the contract and update the stake details.

Users can claim their earned rewards by calling the claim function. This will transfer the rewards to the specified address.

Users can unstake their tokens by calling the unstake function. This will transfer the tokens back to the user and update the stake details accordingly.

Contract Structure
The contract consists of the following main components:

Structs:

Stake: Represents the stake details for a user, including the staked amount, last interaction time, and weight at the last interaction.
Pool: Represents a pool, including the pool volume, total claimed rewards, start time, end time, and weight at the end.
State Variables:

poolId: The current pool ID.
totalStaked: The total amount of MT tokens staked in the contract.
timeToDouble: The time it takes for the contract's weight to double.
prime: The address of the MYToken (MT) contract.
lastInteraction: The timestamp of the last interaction with the contract.
_contractWeight: The total weight of the contract.
unclaimedRewards: The total amount of unclaimed rewards.
poolLength: The duration of each pool in seconds.
_totalSupply: The total supply of MT tokens.
poolLeftOff: A mapping to track the user's pool interaction state.
_balances: A mapping to track the token balances of users.
currentPool: Represents the current pool.
userClaimedPool: A mapping to track whether a user has claimed rewards for a specific pool.
_userWeightAtPool: A mapping to track the user's weight at a specific pool.
stakeDetails: A mapping to store the stake details of users.
poolDetails: A mapping to store the details of each pool.
reward: A mapping to store the claimed reward amount for each user.
Modifiers:

update: Updates the weight of the contract.
Events:

Staked: Triggered when a user stakes tokens.
Unstaked: Triggered when a user unstakes tokens.
Claimed: Triggered when a user claims rewards.
Deployment
To deploy the contract, follow these steps:

Compile the Solidity contract using a Solidity compiler of your choice (e.g., Solidity compiler version 0.8.9).

Deploy the compiled contract to your preferred Ethereum development network (e.g., local development network or testnet) using a tool like Remix, Truffle, or Hardhat.

Set the constructor parameters when deploying the contract:

_timeToDouble: The time it takes for the contract's weight to double.
_poolLength: The duration of each pool in seconds.
_firstPoolStartIn: The delay before the first pool starts in seconds.
_prime: The address of the MYToken (MT) contract.
Interact with the deployed contract by calling the available functions through an Ethereum wallet or a smart contract interaction tool.

Note: Make sure you have the required amount of MYToken (MT) tokens to interact with the contract, and ensure the contract is properly funded with MT tokens for rewards distribution.

License
This project is licensed under the MIT License.

Please refer to the contract code for more details and function documentation.

Feel free to open issues or submit pull requests for any improvements or bug fixes.

Note: The above README file assumes some familiarity with Solidity smart contracts and Ethereum development. It's important to review and customize the README file according to your specific needs and preferences.