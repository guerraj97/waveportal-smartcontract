//Para el curso de buildspace de desarrollo de web3 y smarcontracts
//actualizado al 2 de mayo del 2022
// Jose Pablo Guerra 

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0; //La version de solidity que vamos a usar

import "hardhat/console.sol"; //para el debuggin, hardhat ofrece opciones de debuggin que hace mas sencillo programar un smartcontract.

/*
En general, un smartcontract se ve como cualquier clase en cualquier lenguaje de programacion
Para correrlo se necesita un script. 
*/

contract WavePortal {
    uint256 totalWaves;

    /*
     * We will be using this below to help generate a random number
     */
    uint256 private seed;

    /*
     * A little magic, Google what events are in Solidity!
     * Un evento es una forma de representar en blockchain algo que sucede. Es decir, es la forma como el contrato nos dice
     a nosotros que algo sucedio y podamos verlo reflejado. 

     Events stores the arguments passed in the transaction logs when emitted. 
     Generally, events are used to inform the calling application about the current state of the contract
     */
    event NewWave(address indexed from, uint256 timestamp, string message);

    /*
     * I created a struct here named Wave.
     * A struct is basically a custom datatype where we can customize what we want to hold inside it.
     */
    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

    /*
     * I declare a variable waves that lets me store an array of structs.
     * This is what lets me hold all the waves anyone ever sends to me!
     */
    Wave[] waves;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;

//INICIO DE LAS FUNCIONES DEL SMARTCONTRACT
    constructor() payable {
        console.log("We have been constructed!");
        /*
         * Set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
    }
    /*
     * You'll notice I changed the wave function a little here as well and
     * now it requires a string called _message. This is the message our user
     * sends us from the frontend! -pendiente de desarrollar ese mensaje-
     */
function wave(string memory _message) public {
        /*
         * We need to make sure the current timestamp is at least 30-seconds bigger than the last timestamp we stored
         * En este caso, solo es una condicion anti spam. Podria obviarse, por motivos del curso se deja. 
         */
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 30s"
        );

        /*
         * Update the current timestamp we have for the user
         * lastWavedAt pasa msg.sender que basicamente refers to the immediate account (it could be external or another contract account) 
           that invokes the function.
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1; //actualiza la cantidad total de waves que nos han dado.
        //msg.sender es basicamente el usuario que ha interactuado, por eso lo podemos invocar y vamos a obtener la direccion en consola. 
        console.log("%s has waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp)); //push seria el equivalente a x.append() en python.

        /*
         * Generate a new seed for the next user that sends a wave
         * Este codigo es para un ganador al azar, podria omitirse. Por motivos del curso se deja. 
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than they contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message); //Recuerdan para que eran los eventos? Pues aqui se lanza el evento declarado previamente. 
        //Quien lo envia, la hora y el mensaje. 
    }

    function getAllWaves() public view returns (Wave[] memory) {
        //obtiene todos los waves hasta este momento, pero con la informacion de cada uno
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        //numerito, el total de waves dados.
        return totalWaves;
    }
}