// SPDX-License-Identifier: GPL-3.0

//Version
pragma solidity >=0.7.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "contracts/2_0_TicTacToe_Achievemente.sol";
import "contracts/2_0_TicTacToe_Token.sol";

//Contrato | Juego del gato 
//Slither tool for Code Review Security: https://github.com/crytic/slither
//Correciones y buenas practicas:
// A - Si hacemos muuucho scroll en nuestro contrato es una senial de que tenemos muchisimo codigo en el y que podria mejorarse, separandolo tal vez en diferentes archivos .sol e importarlos...
//  como un helper.sol || por medio de herencia || analizar codigo actual y detectar funcionalidad que se pueda hacer reutilizable mediante una libreria en comun para muchos contratos || ...
//  || la funcion jugar(...) al ser "public" en lugar de "external" hace que gaste mas GAS... esta siempre sera llamada desde el externo y nunca internamente.
//  || lo mismo aplica para todas las funciones que no vayamos a llamar dentro del contrato.
//  || variables uint en realidad son uint256... es necesario declarar todas las varsiables como uint?... se debe analizar ya qu esto malgasta recursos.
//  || bucles "for" se deben usar solamente cuando vamos a recorrer el array por completo... si NO, debemos usar loop "while" con su condicionante correspondiente.
//  || Reutilizar librerias ya probadas y testeadas... no reinventar la rueda... chequear cuanto GAS utilizan!
//  || Todas estas buenas practicas nos ayudan a reducir el uso del GAS y por ende mejorar el performance de nuestro smart contract.
abstract contract TicTacToe is VRFConsumerBaseV2{
    //variables
    struct Partida{
        address jugador1;
        address jugador2;
        address ganador;
        uint[4][4] jugadas;
        address ultimoTurno;
        uint requestId;
    }

    mapping (uint => uint) requestPartidas;
    Partida[] partidas;
    mapping (address => uint) partidasGanadas;
    TicTacToeAchievement achievement;
    TicTacToeToken moneda;
    VRFCoordinatorV2Interface coordinador;
    uint64 idSubscripcion;
    //constructor
    constructor(address contratoAchievement, address contratoMoneda, address pCoordinador, uint64 idSub) VRFConsumerBaseV2(pCoordinador){
        achievement = TicTacToeAchievement(contratoAchievement);
        moneda = TicTacToeToken(contratoMoneda);
        coordinador = VRFCoordinatorV2Interface(pCoordinador);
        idSubscripcion = idSub;
    }

    //funciones
    function crearPartida(address pJugador1, address pJugador2) public returns(uint){
        //validaciones
        require(pJugador1 != pJugador2);
        //nueva partida
        uint idPartida = partidas.length;
        Partida memory partida;
        partida.jugador1 = pJugador1;
        partida.jugador2 = pJugador2;
        partidas.push(partida);

        uint reqId = coordinador.requestRandomWords(
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, 
            idSubscripcion, 
            3, 
            100000, 
            1);
        //requestPartidas[reqId] = partida; //?????
        requestPartidas[reqId] = idPartida;
        return idPartida;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        uint idPartida = requestPartidas[_requestId];
        uint random = _randomWords[0];
        if(random % 2 == 0) {
            partidas[idPartida].ultimoTurno = partidas[idPartida].jugador1;
        }
        else {
            partidas[idPartida].ultimoTurno = partidas[idPartida].jugador2;
        }
    }  

    function jugar(uint idPartida, uint horizontal, uint vertical) external {
        //validaciones
        Partida memory partida = partidas[idPartida];
        require(msg.sender == partida.jugador1 || msg.sender == partida.jugador2);
        require(horizontal > 0 && horizontal < 4);
        require(vertical > 0 && vertical < 4);
        require(msg.sender != partida.ultimoTurno);
        require(partida.jugadas[horizontal][vertical] == 0);
        require(!partidaTerminada(partida));
        require(partida.ultimoTurno != address(0));

        //guardar la jugada
        guardarMovimiento(idPartida, horizontal, vertical);
        partida = partidas[idPartida];

        //checar si hay un ganador o si la matriz esta llena
        uint ganador = obtenerGanador(partida);
        guardarGanador(ganador, idPartida);
        
        partidas[idPartida].ultimoTurno = msg.sender;
    }

    function guardarMovimiento(uint idPartida, uint horizontal, uint vertical) private {
        if(msg.sender == partidas[idPartida].jugador1){
            partidas[idPartida].jugadas[horizontal][vertical] = 1;
        }
        else {
            partidas[idPartida].jugadas[horizontal][vertical] = 2;
        }
    }

    function obtenerGanador(Partida memory partida) private pure returns(uint) {
        //Checar diagonal \
        uint ganador = checarLinea(partida, 1,1,2,2,3,3);
        //Checar diagonal /        
        if(ganador == 0) ganador = checarLinea(partida, 3,1,2,2,1,3);
        //Checar Cols |
        if(ganador == 0) ganador = checarLinea(partida, 1,1,1,2,1,3);
        if(ganador == 0) ganador = checarLinea(partida, 2,1,2,2,2,3);
        if(ganador == 0) ganador = checarLinea(partida, 3,1,3,2,3,3);
        //Checar rows --
        if(ganador == 0) ganador = checarLinea(partida, 1,1,2,1,3,1);
        if(ganador == 0) ganador = checarLinea(partida, 1,2,2,2,3,2);
        if(ganador == 0) ganador = checarLinea(partida, 1,3,2,3,3,3);

        return ganador;
    }
    function checarLinea(Partida memory partida, uint x1, uint y1, uint x2, uint y2, uint x3, uint y3) private pure returns(uint){
        if(partida.jugadas[x1][y1] == partida.jugadas[x2][y2] && partida.jugadas[x2][y2] == partida.jugadas[x3][y3])
        {
            return partida.jugadas[x1][y1];
        }
        else {
            return 0;
        }
    }

    function guardarGanador(uint ganador, uint idPartida) private {
        if(ganador != 0){
            if(ganador == 1){
                partidas[idPartida].ganador = partidas[idPartida].jugador1;
            }
            else {
                partidas[idPartida].ganador = partidas[idPartida].jugador2;
            }
            partidasGanadas[partidas[idPartida].ganador]++;
            if(partidasGanadas[partidas[idPartida].ganador] == 2)
            {
                achievement.emitir(partidas[idPartida].ganador);
            }
            //
            bool casillasDisponibles;
            for(uint x=1; x<4; x++){
               for(uint y=1; y<4; y++){
                    if(partidas[idPartida].jugadas[x][y] == 0) casillasDisponibles = true;
                }
            }
            if(casillasDisponibles) achievement.emitir(partidas[idPartida].ganador);
            //
            //
            if(achievement.balanceOf(partidas[idPartida].ganador) > 0)
            {
                moneda.emitir(partidas[idPartida].ganador, 2);
            }
            else {
                moneda.emitir(partidas[idPartida].ganador, 1);
            }
        }        
    }


    //getting "Warning: Function state mutability can be restricted to pure" when not adding the "pure" word after "private" word.... pure hace la funcion mas liviana
    function partidaTerminada(Partida memory partida) private pure returns(bool) {
        if(partida.ganador != address(0)) return true;

        for(uint x=1; x<4; x++){
            for(uint y=1; y<4; y++){
                if(partida.jugadas[x][y] == 0) return false;
            }
        }
        return true;
    }

    

    //modificadores
}