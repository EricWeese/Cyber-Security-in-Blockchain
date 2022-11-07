pragma solidity ^0.4.18;

contract TransactionOrdering {
    uint public price;
    address public owner;
    
    event Purchase(address _buyer, uint256 _price);
    event PriceChange(address _owner, uint256 _price);
    
    modifier ownerOnly() {
        require(msg.sender == owner, "Not the Owner");
        _;
    }

    function TransactionOrdering()  {
        // constructor
        owner = msg.sender;
        price = 10;
    }

    function buy() external payable returns (uint256)   {
        require(msg.value >= price, "Need to pay more");
        emit Purchase(msg.sender, price);
        return price;
    }

    function setPrice(uint256 _price) ownerOnly() {
        price = _price;
        emit PriceChange(owner, price);
    }
}