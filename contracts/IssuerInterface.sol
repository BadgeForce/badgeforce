pragma solidity ^0.4.15;

contract IssuerInterface {
    function getTransaction(bytes32 _txtKey) constant public returns(bytes32 txtKey, bytes32 integrityHash, address recipient);
    function isRevoked(bytes32 _key) constant public returns(bool c);
}