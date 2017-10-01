pragma solidity ^0.4.15;

import "BadgeLibrary/contracts/BadgeLibrary.sol";
import "./Holder.sol";
import "BadgeForceToken/contracts/BadgeForceToken.sol";


contract Issuer { 

    //access the badgeforce token contract
    BadgeForceToken constant BFT = BadgeForceToken(0x960632c568213c2b583578a7dc7eb4cd2b2bbbfb);
    address constant NONE = 0x0000000000000000000000000000000000000000;
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
    }

    struct IssueTransaction {
        bytes32 key; 
        bytes32 integrityHash;
        address recipient;
    }

    /// @notice mapping of a unique hash to a recipient address, used to verify issuer of a credential 
    mapping (bytes32=>IssueTransaction) public credentialTxtMap;
    mapping (bytes32=>bool) public revokationMap;
    uint private nonce;

    /// @notice storage for earnable badges 
    Vault badgeVault;

    function Issuer(address _issuer, string _name, string _url) {
        issuer = _issuer;
        name = _name;
        url = _url;
        issuerContract = address(this);
        nonce = 0;
    }

    /// @notice make sure caller is the issuer that owns this contract because badgeforce tokens will be used 
    modifier onlyOwner(address _issuer) {
        require(msg.sender == _issuer);
        _;
    }

    /// @notice makes sure badge is unique
    modifier uniqueBadge(string _name) {
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_name);
        BadgeLibrary.BFBadge memory badge = badgeVault.badges[badgeNameHash];
        require(badgeVault.badgeHashNames.length == 0 || badgeVault.badgeHashNames[badge.index] != badgeNameHash);
        _;
    }

    /// @notice checks if a badge exists by name
    modifier badgeExistsN(string _name) {
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_name);
        BadgeLibrary.BFBadge memory badge = badgeVault.badges[badgeNameHash];
        require(badgeVault.badgeHashNames.length > 0 && badgeVault.badgeHashNames[badge.index] == badgeNameHash);
        _;
    }

    /// @notice checks if a badge exists by index
    modifier badgeExists(uint _index) {
        BadgeLibrary.BFBadge memory badge = badgeVault.badges[badgeVault.badgeHashNames[_index]];
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(badge.name);
        require(badgeVault.badgeHashNames.length > 0 && badgeVault.badgeHashNames[_index] == badgeNameHash);
        _;
    }

    event LogCreateBadge(
        string _name,
        address indexed _issuer
    ); 
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
        string _version, 
        string _json) onlyOwner(issuer) uniqueBadge(_name) public
        {   
        //require(BFT.payForCreateBadge(issuer)); 
        _createBadge(
            issuerContract, 
            _description, 
            _name, 
            _image, 
            _version, 
            _json
        );
    }

    event LogIssueCredential(
        string _badgeName,
        address indexed _recipient
    );
    /// @notice issue a new credential to a recipient contract
    /// @param _badgeName name of the badge to issue 
    /// @param _recipient address of the recipient contract
    /// @param _expires expire date (number of weeks)
    function issue(string _badgeName, address _recipient, uint _expires) 
    public onlyOwner(issuer)
    {
        //require(BFT.payForIssueCredential(issuer));
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
    
    /// @notice revoke a credential
    function revoke(bytes32 _txKey) public onlyOwner(issuer) {
        revokationMap[_txKey] = true;
    }

    /// @notice check if credential is revoked
    function getRevoked(bytes32 _key) public constant returns(bool c) {
        return revokationMap[_key];
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
    function _checkTransaction(bytes32 _txtKey, bytes32 _integrityHash, address _recipient) constant public returns(bool _revoked, bool _integrityHashCheck, bool _recipientCheck) {
        
        IssueTransaction memory transaction = credentialTxtMap[_txtKey];
        _revoked = false;
        _integrityHashCheck = false;
        _recipientCheck = false;
        if (transaction.recipient == NONE) {
            return(_revoked, _integrityHashCheck, _recipientCheck);
        } 

        _revoked = revokationMap[transaction.key];
        _integrityHashCheck = (_integrityHash == transaction.integrityHash);
        _recipientCheck = (_recipient == transaction.recipient);

        return(_revoked, _integrityHashCheck, _recipientCheck);

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
        require(badge.issuer != NONE);
        Holder holder = Holder(_recipient);
        holder.storeCredential(
            badge.issuer,
            badge.description,
            badge.name,
            badge.image,
            badge.version,
            badge.json, 
            expires,
            _recipient, 
            _txtKey
        );
        LogIssueCredential(
            badge.name,
            _recipient
        );
    }
    
    /// @notice internal method to call create badge method from library
    function _createBadge(
        address _issuer, 
        string _description, 
        string _name,
        string _image,
        string _version, 
        string _json) private 
        {
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
        string _version, 
        string _json) private 
    {   
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_name);
        BadgeLibrary.BFBadge memory badge = BadgeLibrary.BFBadge(
            _issuer, 
            _description, 
            _name,
            _image, 
            _version,
            _json, 
            badgeVault.badgeHashNames.push(badgeNameHash)-1
        );
        badgeVault.badges[badgeNameHash] = badge;
        LogCreateBadge(badge.name, badge.issuer);
    }

    event LogDeleteBadge(string _name, uint count);
    /// @notice delete a created badge 
    function deleteBadge(string _name) onlyOwner(issuer) badgeExistsN(_name) public returns(bool success) {
        //require(BFT.payForDeleteBadge(issuer));
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_name);
        uint rowToDelete = badgeVault.badges[badgeNameHash].index; 
        bytes32 rowToMove = badgeVault.badgeHashNames[badgeVault.badgeHashNames.length-1]; 
        badgeVault.badgeHashNames[rowToDelete] = rowToMove; 
        badgeVault.badgeHashNames.length--;
        delete badgeVault.badges[badgeNameHash];
        LogDeleteBadge(_name, badgeVault.badgeHashNames.length);
        return true;
    }
 
    // @notice get the number of badges (used by frontend as iterator index to retrieve each badge)
    function getNumberOfBadges() constant public returns(uint count) {
        return badgeVault.badgeHashNames.length;
    }

    /// @notice get a badge by it's index (should be used by frontend in a loop to get all the badges)
    /// @param _index index of the badge to get inside the badge array
    function getBadge(uint _index) constant badgeExists(_index) public returns(
        address _issuer, 
        string _description, 
        string _name, 
        string _image, 
        string _version
    ) {
        bytes32 badgeNameHash = badgeVault.badgeHashNames[_index];
        BadgeLibrary.BFBadge memory badge = badgeVault.badges[badgeNameHash];
        return (
            badge.issuer, 
            badge.description,
            badge.name, 
            badge.image,
            badge.version
        );
    } 

    /// @notice get issuer info
    function getInfo() public constant returns(address _issuer, address _contract, string _name, string _url) {
        return(issuer, issuerContract, name, url);
    }
} 