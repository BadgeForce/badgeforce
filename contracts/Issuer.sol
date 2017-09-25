pragma solidity ^0.4.15;

import "./BadgeLibrary.sol";
import "./Holder.sol";
import "./BadgeForceToken.sol";


contract Issuer {

    //access the badgeforce token contract
    BadgeForceToken constant BFT = BadgeForceToken(0xe365653c027d19375e98d69a400b8b8615974775);

    /// @notice where issuer holds their badgeforce tokens 
    address public issuer;

    /// @notice address of this contract 
    address public issuerContract; 

    string public name;
    string public url;
    
    /// @notice mapping of badgename hash to badge
    /// @notice array of badge hash names
    struct Vault {
        mapping (bytes32=>BadgeLibrary.BFBadge) badges;
        bytes32[] badgeHashNames;
        uint numberOfBadges;
    }

    struct IssueTransaction {
        bytes32 key; 
        bytes32 integrityHash;
        address recipient;
    }

    /// @notice mapping of a unique hash to a recipient address, used to verify issuer of a credential 
    mapping (bytes32=>IssueTransaction) public credentialTxtMap;
    uint private nonce;

    /// @notice storage for earnable badges 
    Vault badgeVault;

    function Issuer(address _issuer, string _name, string _url) {
        issuer = _issuer;
        name = _name;
        url = _url;
        issuerContract = address(this);
        badgeVault.numberOfBadges = 0;
    }

    /// @notice make sure caller is the issuer that owns this contract because badgeforce tokens will be used 
    modifier onlyOwner(address _issuer) {
        require(msg.sender == _issuer);
        _;
    }

    function testHolder(address _recipient) constant returns(address sender) {
        Holder holder = Holder(_recipient);
        return holder.test(_recipient);
    }

    /// @notice create a new badge store it in the badging map 
    /// @param _description Description of the badge 
    /// @param _name name of the badge
    /// @param _image badge image
    /// @param _version badge version
    /// @param _json json string representation
    function createBadge(
        string _description, 
        string _name,
        string _image,
        uint _version, 
        string _json) onlyOwner(issuer) 
        {    
        _createBadge(
            issuerContract, 
            _description, 
            _name, 
            _image, 
            _version, 
            _json
        );
    }

    /// @notice issue a new credential to a recipient contract
    /// @param _badgeName name of the badge to issue 
    /// @param _recipient address of the recipient contract
    /// @param _expires expire date (number of weeks)
    function issue(string _badgeName, address _recipient, uint _expires) 
    public onlyOwner(issuer) 
    {
        bytes32 _txtKey = _getTxtKey(msg.data);
        _setNewTxt(_txtKey, _recipient, _badgeName);
        uint expires;
        if (_expires <= 0) {
            expires = _expires;
        } else {
            expires = now + (_expires * 1 weeks);
        }
        _sendToRecipient(
            _badgeName, 
            _expires, 
            _recipient, 
            _txtKey
        );
    }
    
    /// @notice get a badgeforce transaction key 
    function _getTxtKey(bytes _data) constant public returns (bytes32 txtKey) {
        return BadgeLibrary.credentialTxKey(issuerContract, _data, nonce);
    }
    
    /// @notice get integrity hash of some credential data 
    function _getIntegrityHash(string[] _data) constant private returns (bytes32 _hash) {
        return sha3(_data);
    }

    function _getIssueTransaction(bytes32 _key, bytes32 _integrityHash, address _recipient) constant private returns (IssueTransaction transaction) {
        return IssueTransaction(_key, _integrityHash, _recipient);
    }

    /// @notice set a new transaction (credential issued to recipient)
    /// @param _txtKey the transaction key 
    /// @param _recipient recipient of the credential 
    function _setNewTxt(bytes32 _txtKey, address _recipient, string _badgeName) private onlyOwner(issuer) {
        //increase nonce
        nonce++;
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_badgeName);
        BadgeLibrary.BFBadge memory badge = badgeVault.badges[badgeNameHash];
        bytes32 integrityHash = BadgeLibrary.getIntegrityHash(
            badge.issuer, 
            badge.description, 
            badge.name, 
            badge.image, 
            badge.version, 
            _recipient 
        );
        IssueTransaction memory transaction = _getIssueTransaction(_txtKey, integrityHash, _recipient);
        credentialTxtMap[_txtKey] = transaction;
    }

    /// @notice check that a transaction key exists in the transaction map (verify credential issuer)
    /// @param _txtKey the transaction key to check 
    function _checkTransaction(bytes32 _txtKey, bytes32 _integrityHash, address _recipient) constant returns(bool _keyCheck, bool _integrityHashCheck, bool _recipientCheck) {
        address none = 0x0000000000000000000000000000000000000000;
        IssueTransaction memory transaction = credentialTxtMap[_txtKey];
        _keyCheck = false;
        _integrityHashCheck = false;
        _recipientCheck = false;
        if (transaction.recipient != none) {
            return(_keyCheck, _integrityHashCheck, _recipientCheck);
        } 

        _keyCheck = (_txtKey == transaction.key);
        _integrityHashCheck = (_integrityHash == transaction.integrityHash);
        _recipientCheck = (_recipient == transaction.recipient);

        return(_keyCheck, _integrityHashCheck, _recipientCheck);

    }

    /// @notice internal method that gets instance of recipient contract and stores credential
    function _sendToRecipient(
        string _badgeName, 
        uint expires, 
        address _recipient, 
        bytes32 _txtKey
    ) private 
    {   
        BadgeLibrary.BFBadge memory badge = badgeVault.badges[BadgeLibrary.getBadgeNameHash(_badgeName)];
        Holder holder = Holder(_recipient);
        holder.storeCredential(
            badge.issuer,
            badge.description,
            badge.name,
            badge.image,
            badge.version,
            badge.json,
            false,
            expires,
            _recipient, 
            _txtKey
        );
    }
    
    /// @notice internal method to call create badge method from library
    function _createBadge(
        address _issuer, 
        string _description, 
        string _name,
        string _image,
        uint _version, 
        string _json) private 
        {
        BFT.payForCreateBadge(issuer);
        addBadge(
            _issuer, 
            _description, 
            _name,
            _image, 
            _version,
            _json
        );
    }

    function addBadge(
        address _issuer, 
        string _description, 
        string _name,
        string _image,
        uint _version, 
        string _json) private 
    {
        BadgeLibrary.BFBadge memory badge = BadgeLibrary.BFBadge(
            _issuer, 
            _description, 
            _name,
            _image, 
            _version,
            _json
        );
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_name);
        badgeVault.badgeHashNames.push(badgeNameHash);
        badgeVault.badges[badgeNameHash] = badge;
        badgeVault.numberOfBadges++;
    }

} 