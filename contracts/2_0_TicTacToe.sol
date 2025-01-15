// SPDX-License-Identifier: GPL-3.0

//Version
pragma solidity >=0.7.0 <0.9.0;

//Contrato | Juego del gato
contract TicTacToe{
    //variables
    struct Partida{
        address jugador1;
        address jugador2;
        address ganador;
        uint[4][4] jugadas;
        //address ultimoTurno;
    }

    Partida[] partidas;

    //constructor

    //funciones
    function crearPartida(address pJugador1, address pJugador2) public returns(uint){

    }

    function jugar(uint idPartida, uint horizontal, uint vertical) public {
        //validaciones

        //guardar la jugada

        //checar si hay un ganador o si la matriz esta llena
    }

    //modificadores
}