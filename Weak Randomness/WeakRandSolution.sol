// SPDX-License-Identifier: UNLICENSED

/*This showcases the chainlink oracle to generate a random number for a smart contract.
This code uses the LinkTokenInterface, VRFCoordinatorV2Interface, and VRFConsumerBaseV2 
.sol files from the chianlink github to establish correct tokens, verify owners, and 
generate a random number. Through research I have deemed this as the best way to generate
a verifiably random number*/

pragma solidity ^0.8.7;

//Imports each of the files from the chainlink github
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol"; 
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol"; 
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol"; //This is the main file for the generation of a random number

//creates the VRFv2consumer contract 
contract VRFv2Consumer is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR; //creates coordinator variable
    LinkTokenInterface LINKTOKEN; //creates Link token variable

    //creates variable to hold the subscription for funds
    uint64 s_subscriptionId;

    //These three variable vary on the test network being used (I am using Goleri Test Network)
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    address link = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    //sets the limit on gas allowed to be used for callback transactions
    uint32 callbackGasLimit = 100000;

    //this confirms that the number is indeed random and the request has been confirmed
    uint16 requestConfirmations = 3;

    //Set this number to the amount of random numbers you want generated
    uint32 numWords = 1;


    uint256[] public s_randomWords; //array that holds all generated numbers
    uint256 public s_requestId; //requests for the user ID 
    address s_owner; //holds the owners address

    //constructor takes in the subscription ID then calls VRFConsumerBaseV2
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator){
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator); //gives the coordination value
        LINKTOKEN = LinkTokenInterface(link); //sets up what type of link 
        s_owner = msg.sender; //creates owner with owner id
        s_subscriptionId = subscriptionId; //adds subscription ID to variable
    }

    //function sends the randomWords to generate the number of random numbers as specified
    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        s_randomWords = randomWords;
    }

    //function request random words sets into motion the event of requesting and fulfilling the random words to the owner
    function requestRandomWords() external onlyOwner{
        s_requestId = COORDINATOR.requestRandomWords(keyHash, s_subscriptionId, requestConfirmations, callbackGasLimit, numWords);
    }
    
    //checks to make sure it is the owner and only the owner able to request a number
    modifier onlyOwner(){
        require(msg.sender == s_owner);
        _;
    }
}
