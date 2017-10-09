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

    event AuthorizeAttempt(address _actor, bool authorized);
    /// @notice make sure caller is the issuer that owns this contract because badgeforce tokens will be used 
    modifier authorized(bytes _sig, bytes32 _hash) {
        address _holder = extractAddress(_hash, _sig);
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
    function addTrustedIssuer(address _issuer, bytes _sig, bytes32 _hash) public authorized(_sig, _hash) {
        trustedIssuers[_issuer] = true;
    }

    /// @notice add a new trusted issuer 
    function removeTrustedIssuer(address _issuer, bytes _sig, bytes32 _hash) public authorized(_sig, _hash) {
        trustedIssuers[_issuer] = false;
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

    function extractAddress(bytes32 _hash, bytes _sig) constant returns(address _issuer) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (_sig.length != 65)
          return 0;

        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))

            // Here we are loading the last 32 bytes. We exploit the fact that
            // 'mload' will pad with zeroes if we overread.
            // There is no 'mload8' to do this, but that would be nicer.
            v := byte(0, mload(add(_sig, 96)))

            // Alternative solution:
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            // v := and(mload(add(sig, 65)), 255)
        }

        // albeit non-transactional signatures are not specified by the YP, one would expect it
        // to match the YP range of [27, 28]
        //
        // geth uses [0, 1] and some clients have followed. This might change, see:
        //  https://github.com/ethereum/go-ethereum/issues/2053
        if (v < 27)
          v += 27;

        if (v != 27 && v != 28)
            return 0;

        _issuer = ecrecover(_hash, v, r, s);
        return _issuer;
    }
}