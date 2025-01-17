// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TicTacToeMarketplace is Ownable(msg.sender)  {
    mapping (uint => uint) valores;
    mapping (uint => address) postor;
    IERC721 achievements;
    IERC20 moneda;

    constructor(address contratoMoneda, address contratoAchievement)
    {
        achievements = IERC721(contratoAchievement);
        moneda = IERC20(contratoMoneda);
    }
    function publicar(uint tokenId, uint valor) public {
        require(valores[tokenId] == 0);
        require(valor > 0);
        require(achievements.getApproved(tokenId) == address(this));
        valores[tokenId] = valor;
        postor[tokenId] = msg.sender;
    }

    function finalizacion(uint tokenId) public onlyOwner {
        require(valores[tokenId] > 0);
        require(moneda.allowance(postor[tokenId], address(this)) >= valores[tokenId]);
        require(achievements.getApproved(tokenId) == address(this));

        moneda.transferFrom(postor[tokenId], achievements.ownerOf(tokenId), valores[tokenId]);
        achievements.safeTransferFrom(achievements.ownerOf(tokenId), postor[tokenId], tokenId);
        valores[tokenId] = 0;

    }
    function ofertar(uint tokenId, uint cantidad) public {
        require(valores[tokenId] > 0);
        require(cantidad > valores[tokenId]);
        require(moneda.allowance(msg.sender, address(this)) > cantidad);
        postor[tokenId] = msg.sender;
        valores[tokenId] = cantidad;

    }
    /*
    function comprar(uint tokenId) public {
        require(valores[tokenId] > 0);
        require(moneda.allowance(msg.sender, address(this)) >= valores[tokenId]);
        require(achievements.getApproved(tokenId) == address(this));
        moneda.transferFrom(msg.sender, achievements.ownerOf(tokenId), valores[tokenId]);
        achievements.safeTransferFrom(achievements.ownerOf(tokenId), msg.sender, tokenId);
        valores[tokenId] = 0;
    }
    */
}