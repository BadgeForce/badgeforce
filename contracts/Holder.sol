pragma solidity ^0.4.15;

import "./BadgeLibrary.sol";
import "./Issuer.sol";


contract Holder {
    
    /// @notice address where holder holds there badgeforce tokens
    address public holder;

    /// @notice array of holders credentials 
    BadgeLibrary.BFCredential[] credentials;

    /// @notice mapping of trusted issuers 
    mapping (address=>bool) trustedIssuers;

    string constant INVALID_TRANSACTION = "Invalid transaction: the transaction does not exist";
    string constant INVALID_INTEGRITYHASH = "Invalid data integrity: data in credential does not match original transaction data";
    string constant INVALID_RECIPIENT = "Invalid recipient: recipient does not match original transaction data";
    string constant INVALID_TXTKEY = "Invalid transaction key: transaction keys don't match";
    string constant REVOKED = "Invalid credential: credential revoked";
    string constant VALID_CREDENTIAL = "Credential is valid";

    function Holder(address _holder) {
        holder = _holder;
    }

    function test(address a) returns(address x) {
        return a;
    }

    /// @notice make sure caller is the holder that owns this contract because badgeforce tokens will be used 
    modifier onlyHolder(address _holder) {
        require(msg.sender == _holder);
        _;
    }

    /// @notice make sure issuer is trusted to store credentials on this contract
    modifier trusted(address _issuer) {
        require(trustedIssuers[_issuer]);
        _;
    }

    /// @notice add a new trusted issuer 
    function addTrustedIssuer(address _issuer) onlyHolder(holder) {
        trustedIssuers[_issuer] = true;
    }

    /// @notice store a new credential on this contract 
    function storeCredential(
        address _issuer,
        string _description,
        string _name,
        string _image,
        string _version,
        string _json,
        bool _revoked,
        uint _expires,
        address _recipient,
        bytes32 _txKey
    ) public trusted(msg.sender)
    {
        credentials.push(
            BadgeLibrary.BFCredential(
                _issuer,
                _description,
                _name,
                _image,
                _version,
                _json,
                _revoked,
                _expires,
                _recipient,
                _txKey
        ));
    }

    function verifyCredential(uint credentialIndex) constant public returns(bool verified, string message) {
        BadgeLibrary.BFCredential memory credential = credentials[credentialIndex];
        bytes32 integrityHash = BadgeLibrary.getIntegrityHash(
            credential.issuer, 
            credential.description, 
            credential.name, 
            credential.image, 
            credential.version, 
            credential.recipient
        );
        Issuer issuer = Issuer(credential.issuer);
        var (_keyCheck, _integrityHashCheck, _recipientCheck) = issuer._checkTransaction(
            credential.txKey, 
            integrityHash, 
            credential.recipient
        );
        if (!_keyCheck) {
            return(_keyCheck, INVALID_TRANSACTION);
        } else if (!_recipientCheck) {
            return(_recipientCheck, INVALID_RECIPIENT);
        } else if (!_integrityHashCheck) {
            return(_integrityHashCheck, INVALID_INTEGRITYHASH);
        } else if (credential.revoked) {
            return(false, REVOKED);
        } else {
            return(true, VALID_CREDENTIAL);
        }
    }

    /// @notice get a holders credential 
    /// @param _index index of credential to return 
    function getBadge(uint _index) constant public  returns (
        address _issuer,
        string _description,
        string _name,
        string _image,
        string _version,
        string _json,
        bool _revoked,
        uint _expires,
        address _recipient,
        bytes32 _txKey
    ) {
        require(credentials.length > 0 && _index >= 0);
        BadgeLibrary.BFCredential memory cred = credentials[_index];
        return (
            cred.issuer,
            cred.description,
            cred.name,
            cred.image,
            cred.version,
            cred.json,
            cred.revoked,
            cred.expires,
            cred.recipient,
            cred.txKey
        );
    } 
}