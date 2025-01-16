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
        address ultimoTurno;
    }

    Partida[] partidas;

    //constructor

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
        require(!partidaTerminada(partida));

        //guardar la jugada

        //checar si hay un ganador o si la matriz esta llena
        
        partidas[idPartida].ultimoTurno = msg.sender;
    }

    //getting "Warning: Function state mutability can be restricted to pure" when not adding the "pure" word after "private" word
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