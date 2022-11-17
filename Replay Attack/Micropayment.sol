// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract ReceiverPays {
    address owner = msg.sender;
    //mapping(uint256 => bool) usedNonces;                                                         

    constructor() payable {}
/*
    function claimPayment(uint256 amount, uint256 nonce, bytes memory signature) 
    external {
        require(!usedNonces[nonce]);
        usedNonces[nonce] = true;

        // Recreates the message that was signed on the client for signature validation
        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));

        require(recoverSigner(message, signature) == owner);                                        

        payable(msg.sender).transfer(amount);
    }
*/
    function claimPayment(uint256 amount, bytes memory signature) 
    external {
        // Recreates the message that was signed on the client for signature validation
        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount)));

        require(recoverSigner(message, signature) == owner);                                        

        payable(msg.sender).transfer(amount);
    }

    // Destroys contract and sends any remaining funds to the owner of the contract
    function shutdown() external {
        require(msg.sender == owner);
        selfdestruct(payable(msg.sender));
    }

    //  Splits signature into (r, s, v) components
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            // First 32 bytes, after the length prefix ":\32..."
            r := mload(add(sig, 32))
            // Next 32 bytes
            s := mload(add(sig, 64))
            // First byte of the next 32 bytes
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }


    //Uses message sent to verify original signer (or owner of the contract)
    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    // Builds prefixed hash to mimic the behavior of eth_sign
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}