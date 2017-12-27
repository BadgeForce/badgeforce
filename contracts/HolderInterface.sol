pragma solidity ^0.4.15;

contract HolderInterface {
    
    function getCredential(bytes32 _txtKey) constant public  returns (
        address _issuer,
        string _description,
        string _name,
        string _image,
        string _version,
        uint _expires,
        address _recipient,
        bytes32 _txKey
    );

    function storeCredential(
        address _issuer,
        string _description,
        string _name,
        string _image,
        string _version,
        uint _expires,
        address _recipient,
        bytes32 _txKey
    ) public;
}