pragma solidity ^0.4.18;

contract SolutionTransactionOrdering {
  uint256 price;
  uint256 txCounter;
  address owner;
  
  event Purchase(address _buyer, uint256 _price);
  event PriceChange(address _owner, uint256 _price);
  
  modifier ownerOnly() {
    require(msg.sender == owner);
    _;
  }
  function getPrice() constant returns (uint256) {
    return price;
  }

  function getTxCounter() constant returns (uint256) {
    return txCounter;
  }

  function SolutionTransactionOrdering() {
    // constructor
    owner = msg.sender;
    price = 10;
    txCounter = 0;
  }

  function buy(uint256 _txCounter) external payable returns (uint256) {
    require(_txCounter == txCounter, "Price was changed");
    require(msg.value >= price, "Need to pay more");
    Purchase(msg.sender, price);
    return price;
  }

  function setPrice(uint256 _price) ownerOnly() {
    price = _price;
    txCounter += 1;
    PriceChange(owner, price);
  }
}