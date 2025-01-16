// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TicTacToeToken is ERC20, Ownable(msg.sender) {
    constructor() ERC20("Token Modena", "TTT") {}

    function emitir(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}