pragma solidity ^0.4.15;


library PaymentLibrary {

    uint constant BASE = 10**18;
    uint256 constant CREATE_BADGE_COST = 25*BASE;
    uint256 constant DELETE_BADGE_COST = 12*BASE;
    uint256 constant ISSUE_CREDENTIAL_COST = 50*BASE;
    uint256 constant VERIFY_CREDENTIAL_COST = 15*BASE;

    function getCreateBadgeCost() constant returns(uint256 cost) {
        return CREATE_BADGE_COST;
    }

    function getIssueCredentialCost() constant returns(uint256 cost) {
        return ISSUE_CREDENTIAL_COST;
    }

    function getVerifyCredentialCost() constant returns(uint256 cost) {
        return VERIFY_CREDENTIAL_COST;
    }

    function payDeleteBadgeCost() constant returns(uint256 cost) {
        return DELETE_BADGE_COST;
    }
}