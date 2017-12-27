pragma solidity ^0.4.15;

import "BadgeLibrary/contracts/BadgeLibrary.sol";
import "BadgeLibrary/contracts/VerifierInterface.sol";
import "BadgeLibrary/contracts/VerifierLibrary.sol";

contract Holder {
    
    /// @notice address where holder holds there badgeforce tokens
    address public holder;

    VerifierInterface verifier;

    /// @notice mapping of name hash to credential
    /// @notice array of hash names
    struct CredentialVault {
        mapping (bytes32=>BadgeLibrary.Credential) credentials;
        mapping (bytes32=>uint) indexMap;
        bytes32[] keys;
    }

    /// @notice valut holding credentials
    CredentialVault credentialVault;

    /// @notice mapping of trusted issuers 
    mapping (address=>bool) public trustedIssuers;

    function Holder(address _holder, address _verifier) {
        holder = _holder;
        verifier = VerifierInterface(_verifier);
    }

    event AuthorizeAttempt(address _actor, bool authorized);
    /// @notice make sure caller is the issuer that owns this contract because badgeforce tokens will be used 
    modifier authorized(address _holder) {
        bool isAuthorized = (_holder == holder);
        AuthorizeAttempt(_holder, isAuthorized);
        require(isAuthorized);
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
    function addTrustedIssuer(address _issuer) public authorized(msg.sender) {
        trustedIssuers[_issuer] = true;
    }

    /// @notice add a new trusted issuer 
    function removeTrustedIssuer(address _issuer) public authorized(msg.sender) {
        trustedIssuers[_issuer] = false;
    }

    event LogNewCredential(address _issuer, bytes32 _txKey);
    /// @notice store a new credential on this contract 
    function storeCredential(
        address _issuer,
        string _description,
        string _name,
        string _image,
        string _version,
        uint _expires,
        address _recipient,
        bytes32 _txKey
    ) public trusted(msg.sender)
    {
        BadgeLibrary.Badge memory badgeData = BadgeLibrary.Badge(
            _issuer,
            _description,
            _name,
            _image,
            _version
        );
        BadgeLibrary.Credential memory credential = BadgeLibrary.Credential(
                badgeData,
                _expires,
                _recipient,
                _txKey
        );
        credentialVault.credentials[_txKey] = credential;
        credentialVault.indexMap[_txKey] = credentialVault.keys.push(_txKey)-1;
        LogNewCredential(_issuer, _txKey);
    }

    event CredentialDeleted(bytes32 _txKey, uint count);
    /// @notice delete a credential 
    function deleteCredential(bytes32 _txKey) 
    authorized(msg.sender)
    public returns(bool success) 
    {
        delete credentialVault.credentials[_txKey];
        uint rowToDelete = credentialVault.indexMap[_txKey]; 
        bytes32 rowToMove = credentialVault.keys[credentialVault.keys.length-1];
        credentialVault.indexMap[rowToMove] = rowToDelete; 
        credentialVault.keys[rowToDelete] = rowToMove; 
        credentialVault.keys.length--;
        delete credentialVault.indexMap[_txKey];
        delete credentialVault.credentials[_txKey];
        CredentialDeleted(_txKey, credentialVault.keys.length);
        return true;
    }

    /// @notice get a holders credential 
    /// @param _name index of credential to return 
    function getCredential(bytes32 _txtKey) constant public  returns (
        address _issuer,
        string _description,
        string _name,
        string _image,
        string _version,
        uint _expires,
        address _recipient,
        bytes32 _txKey
    ) {
        require(credentialVault.keys.length > 0);
        BadgeLibrary.Credential memory cred = credentialVault.credentials[_txtKey];
        return (
            cred.badge.issuer,
            cred.badge.description,
            cred.badge.name,
            cred.badge.image,
            cred.badge.version,
            cred.expires,
            cred.recipient,
            cred.txKey
        );
    }

    /// @notice helper function for UI to retrieve all names then retrieve the credentials
    /// @param _index index of the name you want
    function getTxtKey(uint _index) constant public returns(bytes32 name) {
        return credentialVault.keys[_index];
    }

    /// @notice get number of credentials 
    function getNumberOfCredentials() constant public returns(uint count) {
        return credentialVault.keys.length;
    }

    function verifyCredential(bytes32 _txtKey) constant public returns(bytes32 b) {
        //bytes32 _txtKey, bytes32 _integrityHash, address _recipient, address _issuer
        BadgeLibrary.Credential memory credential = credentialVault.credentials[_txtKey];
        bytes32 integrityHash = VerifierLibrary.getIntegrityHash(
            credential.badge.issuer, 
            credential.badge.description, 
            credential.badge.name, 
            credential.badge.image, 
            credential.badge.version, 
            credential.expires,
            credential.recipient 
        );
        return integrityHash;
        // return verifier.verifyCredential(credential.txKey, integrityHash, credential.recipient, credential.badge.issuer);
    }
}