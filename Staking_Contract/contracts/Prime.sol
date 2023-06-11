// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract Prime is ERC20,Ownable  {
    constructor(uint amount) ERC20("MyToken", "MTK") {
        _mint(msg.sender, amount);
    }
    
    function mintToken(address to,uint amount) external onlyOwner {
        _mint(to, amount);
    }
}
