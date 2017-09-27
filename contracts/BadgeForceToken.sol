/*
This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL extras intended for use by humans.

In other words. This is intended for deployment in something like a Token Factory or Mist wallet, and then used by humans.
Imagine coins, currencies, shares, voting weight, etc.
Machine-based, rapid creation of many tokens would not necessarily need these extra features or will be minted in other manners.

1) Initial Finite Supply (upon creation one specifies how much is minted).
2) In the absence of a token registry: Optional Decimal, Symbol & Name.
3) Optional approveAndCall() functionality to notify a contract if an approval() has occurred.

.*/

pragma solidity ^0.4.15;

import "./StandardToken.sol";
import "./PaymentLibrary.sol";


contract BadgeForceToken is StandardToken {
    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string constant public name = "BadgeForceToken";                   //fancy name: eg Simon Bucks
    uint8 constant public decimals = 18;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string constant public symbol = "BFT";                 //An identifier: eg SBX
    string constant public version = "BFT.1";       //human 0.1 standard. Just an arbitrary versioning scheme.
    uint256 constant public INITIAL_SUPPLY = 1*(10**9)*(10**18);


    function BadgeForceToken() {
        balances[msg.sender] = INITIAL_SUPPLY; 
        totalSupply = INITIAL_SUPPLY;       
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

    function payForCreateBadge(address _payee) returns(bool success) {
        uint256 cost = PaymentLibrary.getCreateBadgeCost();
        require(balances[_payee] >= cost);
        balances[_payee] -= cost;
        return true;
    }

    function payForIssueCredential(address _payee) returns(bool success) {
        uint256 cost = PaymentLibrary.getIssueCredentialCost();
        require(balances[_payee] >= cost);
        balances[_payee] -= cost;
        return true;
    }

    function payForVerifyCredential(address _payee) returns(bool success) {
        uint256 cost = PaymentLibrary.getVerifyCredentialCost();
        require(balances[_payee] >= cost);
        balances[_payee] -= cost;
        return true;
    }

    function payForDeleteBadge(address _payee) returns(bool success) {
        uint256 cost = PaymentLibrary.payDeleteBadgeCost();
        require(balances[_payee] >= cost);
        balances[_payee] -= cost;
        return true;
    }
}