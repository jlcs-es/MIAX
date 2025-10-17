// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8.2 < 0.9.0;

contract Ownable {
    address owner;
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Se requiere el owner del contrato");
        _;
    }
}


contract Votacion is Ownable {
    enum State {NO_INICIADA, INICIADA, FINALIZADA}

    struct Candidatura {
        uint256 votos;
        bool registrada;
    }
    
    event VotacionIniciada();
    event VotacionFinalizada(string winner);

    State public state;
    mapping(string nombre => Candidatura) candidaturas;
    mapping(address votante => bool) votantes;
    uint256 numCandidatos;

    string currentWinner;
    uint256 maxVotos;

    modifier onlyState(State s) {
        require(state == s, "Not in valid state");
        _;
    }

    function anadirCandidato(string memory nombre) public onlyOwner onlyState(State.NO_INICIADA) {
        require(!candidaturas[nombre].registrada, "Ya registrada");
        candidaturas[nombre] = Candidatura(0, true);
        numCandidatos += 1;
    }

    function iniciarVotacion() public onlyOwner onlyState(State.NO_INICIADA) {
        require(numCandidatos > 0, "no hay candidatos");
        state = State.INICIADA;
        emit VotacionIniciada();
    }

    function votar(string memory nombre) public onlyState(State.INICIADA) {
        require(!votantes[msg.sender], "ya has votado");
        require(candidaturas[nombre].registrada, "candidatura no registrada");
        votantes[msg.sender] = true;
        candidaturas[nombre].votos += 1;

        if (candidaturas[nombre].votos > maxVotos) {
            maxVotos = candidaturas[nombre].votos;
            currentWinner = nombre;
        }
    }

    function finalizar() public onlyOwner onlyState(State.INICIADA) {
        state = State.FINALIZADA;
        emit VotacionFinalizada(currentWinner);
    }
}
