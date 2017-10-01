pragma solidity ^0.4.15;

import "BadgeLibrary/contracts/BadgeLibrary.sol";
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

    event LogAccessAttempt(address _caller, string _func);
    /// @notice make sure caller is the holder that owns this contract because badgeforce tokens will be used 
    modifier onlyHolder(address _holder, string _func) {
        LogAccessAttempt(_holder, _func);
        require(msg.sender == _holder);
        _;
    }

    event LogStoreAttempt(address _caller);
    /// @notice make sure issuer is trusted to store credentials on this contract
    modifier trusted(address _issuer) {
        LogStoreAttempt(_issuer);
        require(trustedIssuers[_issuer]);
        _;
    }

    /// @notice add a new trusted issuer 
    function addTrustedIssuer(address _issuer) public onlyHolder(holder, "addTrustedIssuer") {
        trustedIssuers[_issuer] = true;
    }

    event LogNewCredential(address _issuer, string name);
    /// @notice store a new credential on this contract 
    function storeCredential(
        address _issuer,
        string _description,
        string _name,
        string _image,
        string _version,
        string _json,
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
                _expires,
                _recipient,
                _txKey
        ));
        LogNewCredential(_issuer, _name);
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
        var (_revoked, _integrityHashCheck, _recipientCheck) = issuer._checkTransaction(
            credential.txKey, 
            integrityHash, 
            credential.recipient
        );
        if (_revoked) {
            return(false, REVOKED);
        } else if (!_recipientCheck) {
            return(_recipientCheck, INVALID_RECIPIENT);
        } else if (!_integrityHashCheck) {
            return(_integrityHashCheck, INVALID_INTEGRITYHASH);
        } else {
            return(true, VALID_CREDENTIAL);
        }
    }

    /// @notice get a holders credential 
    /// @param _index index of credential to return 
    function getCredential(uint _index) constant public  returns (
        address _issuer,
        string _description,
        string _name,
        string _image,
        string _version,
        string _json,
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
            cred.expires,
            cred.recipient,
            cred.txKey
        );
    }

    /// @notice get number of credentials 
    function getNumberOfCredentials() constant public returns(uint count) {
        return credentials.length;
    }
}