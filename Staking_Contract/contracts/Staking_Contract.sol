// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title Stacking Contract
/// @notice A smart contract for staking tokens and earning rewards
contract Stacking is ERC20,ReentrancyGuard {
    using SafeERC20 for IERC20;
   
    // Error definitions
    error Insuffient_balance();
    error InvalidPool();
    error ClaimedUpToPool();
    error NothingStaked();
    
    // Events
    event StakeDetails(
        address indexed from,
        uint256 newAmount,
        uint256 newWeightAmount
    );

    event Unstaked(address from ,uint amount);
    
    // Structs

    /// @dev Represents stake details for a user
    struct Stake {
        uint256 amountStaked;           // Amount of tokens staked by the user
        uint256 lastInteraction;        // Timestamp of the last interaction with the stake
        uint256 weightAtLastInteraction; // Stake weight at the time of the last interaction
    }

    /// @dev Represents a staking pool
    struct Pool {
        uint256 volume;         // Total volume of tokens in the pool
        uint256 totalClaimed;   // Total tokens claimed from the pool
        uint256 startTime;      // Start time of the pool
        uint256 endTime;        // End time of the pool
        uint256 weightAtEnd;    // Stake weight at the end of the pool
    }
   // State variables
    uint256 public poolId;               // ID of the current pool
    uint256 public totalStaked;          // Total amount of tokens staked
    uint256 public timeToDouble;         // Time period for doubling stake weight
    address public immutable prime;      // Address of the prime contract
    uint256 public lastInteraction;      // Timestamp of the last interaction with the contract
    uint256 public _contractWeight;      // Stake weight of the contract
    uint256 public unclaimedRewards;     // Total unclaimed rewards
    uint256 public poolLength;           // Total number of pools
    uint256 private _totalSupply;        // Total supply of the stacking token
    mapping(address => uint256) public poolLeftOff;  // Mapping of user's pool position
    mapping(address => uint256) private _balances;  // Mapping of user's token balances
    Pool public currentPool;             // Current pool details
    mapping(address => mapping(uint256 => bool)) public userClaimedPool;  // Mapping of user's claimed pool
    mapping(address => mapping(uint256 => uint256)) public _userWeightAtPool;  // Mapping of user's stake weight at a pool
    mapping(address => Stake) public stakeDetails;  // Mapping of user's stake details
    mapping(uint256 => Pool) public poolDetails;  // Mapping of pool ID to pool details
    mapping(address => uint256) public claimLeftOff;  // Mapping of user's claim position

    
    /// @dev Constructor function.
    /// @param _timeToDouble Time period for doubling stake weight
    /// @param _poolLength Total number of pools
    /// @param _firstPoolStartIn Time until the first pool starts
    /// @param _prime Address of the prime contract
    constructor(
        uint256 _timeToDouble,
        uint256 _poolLength,
        uint256 _firstPoolStartIn,
        address _prime
    ) ERC20("MYToken", "MT") {
        prime =_prime;
        timeToDouble = _timeToDouble;
        poolLength = _poolLength;
        currentPool.endTime = block.timestamp + _firstPoolStartIn;
        poolDetails[0].endTime = block.timestamp + _firstPoolStartIn;
        currentPool.startTime = block.timestamp;
        poolDetails[0].startTime = block.timestamp;
    }
    
    /**
     * @dev Mints new tokens and assigns them to the specified account.
     * @param account The account to mint tokens for.
     * @param amount The amount of tokens to mint.
     */
    function mintToken(address account,uint256 amount) external {
        require(account != address(0), "ERC20: mint to the zero address");
        _update(address(0), account, amount);
    }
    
    /**
     * @dev Returns the token balance of the specified account.
     * @param account The account to retrieve the balance for.
     * @return The token balance of the account.
     */
    function balanceOf(address account) public view virtual override  returns (uint256) {
        return _balances[account];
    }
    
    /**
     * @dev Internal function to update token balances during transfers.
     * @param from The account to transfer tokens from.
     * @param to The account to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     */
    function _update(address from, address to, uint256 amount) internal virtual  {
        if (from == address(0)) {
            _totalSupply += amount;
        } else {
            uint256 fromBalance = _balances[from];
            require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                // Overflow not possible: amount <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - amount;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: amount <= totalSupply or amount <= fromBalance <= totalSupply.
                _totalSupply -= amount;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + amount is at most totalSupply, which we know fits into a uint256.
                _balances[to] += amount;
            }
        }

        emit Transfer(from, to, amount);
    }
     /**
     * @dev Transfers tokens from the sender's account to the specified account.
     * @param to The account to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return True if the transfer is successful, false otherwise.
     */
     function transfer(address to, uint256 amount) public virtual override  returns (bool) {
        address owner =_msgSender();
        _transfer(owner, to, amount);
        return true;
    }

     function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _update(from, to, amount);
    }

    function _msgSender() internal view virtual override  returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        return msg.data;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev Stakes a specified amount of tokens.
     * @param amount The amount of tokens to stake.
     */
    function stak(uint256 amount) external {
        if (balanceOf(msg.sender) < amount) {
            revert Insuffient_balance();
        }
        transfer(address(this), amount);
         updatePool();
        _setUserWeightAtPool(msg.sender);
        _adjustContractWeight(true, amount);
        
        totalStaked += amount; 
       Stake memory _stake = stakeDetails[msg.sender];

        if (_stake.amountStaked > 0) {
            uint256 _additionalWeight = _weightIncreaseSinceInteraction(
                block.timestamp,
                _stake.lastInteraction,
                _stake.amountStaked
            );
            _stake.weightAtLastInteraction += (_additionalWeight + amount);
        } else {
            _stake.weightAtLastInteraction = amount;
        }

        _stake.amountStaked += amount;
        _stake.lastInteraction = block.timestamp;

        stakeDetails[msg.sender] = _stake;

        emit StakeDetails(msg.sender, _stake.amountStaked, _stake.weightAtLastInteraction);
    }
    
    /**
     * @dev Claims the pending rewards for the caller.
     * @param _to The address to send the claimed rewards to.
     */
    function claim(address _to) external nonReentrant {
        _setUserWeightAtPool(msg.sender);

        uint256 _pendingRewards;
        uint256 _claimLeftOff = claimLeftOff[msg.sender];

        if (_claimLeftOff == poolId) revert ClaimedUpToPool();

        for (_claimLeftOff; _claimLeftOff < poolId; ++_claimLeftOff) {
            if (!userClaimedPool[msg.sender][_claimLeftOff] && contractWeightAtPool(_claimLeftOff) > 0) {
                userClaimedPool[msg.sender][_claimLeftOff] = true;
                Pool memory _pool = poolDetails[_claimLeftOff];
                uint256 _weightAtPool = _userWeightAtPool[msg.sender][_claimLeftOff];

                uint256 _poolRewards = (_pool.volume * _weightAtPool) /
                    contractWeightAtPool(_claimLeftOff);
                if (_pool.totalClaimed + _poolRewards > _pool.volume) {
                    _poolRewards = _pool.volume - _pool.totalClaimed;
                }

                _pendingRewards += _poolRewards;
                poolDetails[_claimLeftOff].totalClaimed += _poolRewards;
            }
        }
      
        claimLeftOff[msg.sender] = poolId;
        unclaimedRewards -= _pendingRewards;
        IERC20(prime).safeTransfer(_to, _pendingRewards);
    }
    /**
     * @dev Unstakes the tokens currently staked by the caller.
     * @param _to The address to send the unstaked tokens to.
     */
     function unstake(address _to) external nonReentrant {
        Stake memory _stake = stakeDetails[msg.sender];
        
        uint256 _stakedAmount = _stake.amountStaked;

        if (_stakedAmount == 0) revert NothingStaked();

        updatePool();
        _setUserWeightAtPool(msg.sender);
        _adjustContractWeight(false, _stakedAmount);

        totalStaked -= _stakedAmount;

        _stake.amountStaked = 0;
        _stake.lastInteraction = block.timestamp;
        _stake.weightAtLastInteraction = 0;

        stakeDetails[msg.sender] = _stake;
        _balances[address(this)]-=_stakedAmount;
        _balances[_to]+=_stakedAmount;
      

        emit Unstaked(msg.sender, _stakedAmount);
    }

     /**
     * @dev Returns the weight of the specified user at the specified pool.
     * @param _user The user address.
     * @param _poolId The pool ID.
     * @return userWeight_ The weight of the user at the pool.
     */
     
    function userWeightAtPool(address _user, uint256 _poolId) public view returns (uint256 userWeight_) {
        if (poolId <= _poolId) revert InvalidPool();
        uint256 _poolLeftOff = poolLeftOff[_user];
        Stake memory _stake = stakeDetails[_user];

        if (_poolLeftOff > _poolId) userWeight_ = _userWeightAtPool[_user][_poolId];
        else {
            Pool memory _pool = poolDetails[_poolId];
            if (_stake.amountStaked > 0) {
                uint256 _additionalWeight = _weightIncreaseSinceInteraction(
                    _pool.endTime,
                    _stake.lastInteraction,
                    _stake.amountStaked
                );
                userWeight_ = _additionalWeight + _stake.weightAtLastInteraction;
            }
        }
    }

    /**
     * @dev Sets the user's weight at each pool up to the current pool.
     * @param _user The user address.
     */
    function _setUserWeightAtPool(address _user) internal {
        uint256 _poolLeftOff = poolLeftOff[_user];

        if (_poolLeftOff != poolId) {
            Stake memory _stake = stakeDetails[_user];
            if (_stake.amountStaked > 0) {
                for (_poolLeftOff; _poolLeftOff < poolId; ++_poolLeftOff) {
                    Pool memory _pool = poolDetails[_poolLeftOff];
                   
                    uint256 _additionalWeight = _weightIncreaseSinceInteraction(
                        _pool.endTime,
                        _stake.lastInteraction,
                        _stake.amountStaked
                    );
                    
                    _userWeightAtPool[_user][_poolLeftOff] =
                        _additionalWeight +
                        _stake.weightAtLastInteraction;
                }
            }
         
            poolLeftOff[_user] = poolId;
        }
    }
    
    /**
     * @dev Updates the current pool if the current time exceeds the pool end time.
     */
    function updatePool() internal {
        if (block.timestamp >= currentPool.endTime) {
           
            uint256 _additionalWeight = _weightIncreaseSinceInteraction(
                currentPool.endTime,
                lastInteraction,
                totalStaked
            );
           
            poolDetails[poolId].weightAtEnd =
                _additionalWeight +
                _contractWeight;
         
            ++poolId;

            Pool memory _pool;
            _pool.volume = IERC20(prime).balanceOf(address(this)) - unclaimedRewards;
            _pool.startTime = block.timestamp;
            _pool.endTime = block.timestamp + poolLength;
          
            currentPool = _pool;
            poolDetails[poolId] = _pool;
          
            unclaimedRewards += _pool.volume;
        }
    }
     /**
     * @dev Calculates the additional weight increase since the last interaction.
     * @param _timestamp The current timestamp.
     * @param _lastInteraction The timestamp of the last interaction.
     * @param _baseAmount The base amount to calculate the additional weight increase.
     * @return additionalWeight_ The additional weight increase.
     */
    function _weightIncreaseSinceInteraction(
        uint256 _timestamp,
        uint256 _lastInteraction,
        uint256 _baseAmount
    ) internal view returns (uint256 additionalWeight_) {
        uint256 _timePassed = _timestamp - _lastInteraction;
        uint256 _multiplierReceived = (1e18 * _timePassed) / timeToDouble;
        additionalWeight_ = (_baseAmount * _multiplierReceived) / 1e18;
    }
    /**
     * @dev Adjusts the contract's weight based on stake or unstake actions.
     * @param _stake A boolean indicating if it's a stake action (true) or unstake action (false).
     * @param _amount The amount being staked or unstaked.
     */
    function _adjustContractWeight(bool _stake, uint256 _amount) internal {
        uint256 _weightReceivedSinceInteraction = _weightIncreaseSinceInteraction(
                block.timestamp,
                lastInteraction,
                totalStaked
            );
        _contractWeight += _weightReceivedSinceInteraction;

        if (_stake) {
            _contractWeight += _amount;
        } else {
            if (userTotalWeight(msg.sender) > _contractWeight)
                _contractWeight = 0;
            else _contractWeight -= userTotalWeight(msg.sender);
        }

        lastInteraction = block.timestamp;
    }
    /**
     * @dev Retrieves the total weight of a user.
     * @param _user The user's address.
     * @return userWeight_ The total weight of the user.
     */
    function userTotalWeight(address _user)
        public
        view
        returns (uint256 userWeight_)
    {
        Stake memory _stake = stakeDetails[_user];
        uint256 _additionalWeight = _weightIncreaseSinceInteraction(
            block.timestamp,
            _stake.lastInteraction,
            _stake.amountStaked
        );
        userWeight_ = _additionalWeight + _stake.weightAtLastInteraction;
    }
    /**
     * @dev Retrieves the contract's weight at a specific pool.
     * @param _poolId The ID of the pool.
     * @return contractWeight_ The contract's weight at the specified pool.
     */

    function contractWeightAtPool(uint256 _poolId)
        public
        view
        returns (uint256 contractWeight_)
    {
        if (poolId <= _poolId) revert InvalidPool();
        return poolDetails[_poolId].weightAtEnd;
    }
    /**
     * @dev Retrieves the current contract's weight.
     * @return contractWeight_ The current contract's weight.
     */
    function contractWeight() external view returns (uint256 contractWeight_) {
        uint256 _weightIncrease = _weightIncreaseSinceInteraction(
            block.timestamp,
            lastInteraction,
            totalStaked
        );
        contractWeight_ = _weightIncrease + _contractWeight;
    }

     /**
     * @dev Retrieves the pending rewards that haven't been claimed yet.
     * @return pendingRewards_ The amount of pending rewards.
     */
   function pendingRewards() external view returns (uint256 pendingRewards_) {
        return IERC20(prime).balanceOf(address(this)) - unclaimedRewards;
    }
    /**
     * @dev Calculates the claimable rewards for a specific pool and user.
     * @param _user The user's address.
     * @param _poolId The ID of the pool.
     * @return claimable_ The amount of rewards claimable by the user in the specified pool.
     */
    function claimAmountForPool(address _user, uint256 _poolId) external view returns (uint256 claimable_) {
        if (poolId <= _poolId) revert InvalidPool();
        if (userClaimedPool[_user][_poolId] || contractWeightAtPool(_poolId) == 0) return 0;

        Pool memory _pool = poolDetails[_poolId];

        claimable_ = (_pool.volume * userWeightAtPool(_user, _poolId)) / contractWeightAtPool(_poolId);
    }

    
}