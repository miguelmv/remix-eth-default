// SPDX-License-Identifier: GPL-3.0

//Version
pragma solidity >=0.7.0 <0.9.0;

import "contracts/2_0_TicTacToe_Achievemente.sol";
import "contracts/2_0_TicTacToe_Token.sol";

//Contrato | Juego del gato
contract TicTacToe{
    //variables
    struct Partida{
        address jugador1;
        address jugador2;
        address ganador;
        uint[4][4] jugadas;
        address ultimoTurno;
    }

    Partida[] partidas;
    mapping (address => uint) partidasGanadas;
    TicTacToeAchievement achievement;
    TicTacToeToken moneda;
    //constructor
    constructor(address contratoAchievement, address contratoMoneda){
        achievement = TicTacToeAchievement(contratoAchievement);
        moneda = TicTacToeToken(contratoMoneda);
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
        return idPartida;
    }

    function jugar(uint idPartida, uint horizontal, uint vertical) public {
        //validaciones
        Partida memory partida = partidas[idPartida];
        require(msg.sender == partida.jugador1 || msg.sender == partida.jugador2);
        require(horizontal > 0 && horizontal < 4);
        require(vertical > 0 && vertical < 4);
        require(msg.sender != partida.ultimoTurno);
        require(partida.jugadas[horizontal][vertical] == 0);
        require(!partidaTerminada(partida));

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

            moneda.emitir(partidas[idPartida].ganador, 1);
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