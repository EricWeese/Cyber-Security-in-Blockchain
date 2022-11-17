pragma solidity ^0.8.13;

contract WinnerOfEther {
    address public winner;
    uint public balance;
    mapping(address => uint) public balances;

    function claimContract() external payable {
        require(msg.value > balance, "Need to pay more to become the winner");

        balances[winner] += balance;

        balance = msg.value;
        winner = msg.sender;
    }

    function withdraw() public {
        require(msg.sender != winner, "Current winner cannot withdraw");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}