pragma solidity ^0.4.15;


contract Credential {

    address issuer;
    address recipient;
    bool revoked;
    string expires;

    //the address of the badge that was earned, should be set when token is sent (credential issued)
    address badgeAddress;

    function Credential(address _recipient, string _expires, address _badgeAddress) {
        issuer = msg.sender;
        recipient = _recipient;
        expires = _expires;
        revoked = false;
        badgeAddress = _badgeAddress;
    }

}
