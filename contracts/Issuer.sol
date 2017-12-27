pragma solidity ^0.4.15;

import "BadgeLibrary/contracts/BadgeLibrary.sol";
import "BadgeLibrary/contracts/VerifierInterface.sol";
import "BadgeLibrary/contracts/VerifierLibrary.sol";
import "BadgeForceToken/contracts/BadgeForceToken.sol";

import "./IssuerInterface.sol";
import "./HolderInterface.sol";


contract Issuer is IssuerInterface {
    //access the badgeforce token contract
    BadgeForceToken private BFT;

    // badgeforce verifier v1
    VerifierInterface verifier;

    address constant NONE = 0x0000000000000000000000000000000000000000;
    /// @notice the god account for this contract
    address public admin;

    struct AuthorizedAccount {
        address issuer;
        uint index;
        bool isAuthorized;
    }
    /// @notice authorized issuers on this contract
    mapping (address=>AuthorizedAccount) public authorizedAccountsMap;
    /// @notice list of authorized acounts
    address[] authorizedAccountsList;

    /// @notice address of this contract 
    address public issuerContract; 

    string public name;
    string public url;
    
    /// @notice mapping of badgename hash to badge
    /// @notice array of badge hash names
    struct Vault {
        mapping (bytes32=>BadgeLibrary.Badge) badges;
        mapping (bytes32=>uint) indexMap;
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
    uint private nonce = 0;

    /// @notice storage for earnable badges 
    Vault badgeVault;

    function Issuer(address _issuer, string _name, string _url, address _token, address _verifier) {
        admin = _issuer;
        name = _name;
        url = _url;
        issuerContract = address(this);
        nonce = 0;
        BFT = BadgeForceToken(_token);
        verifier = VerifierInterface(_verifier);
    }

    event AuthorizeAttempt(address _actor, bool authorized);
    /// @notice make sure caller is the issuer that owns this contract because badgeforce tokens will be used 
    modifier authorized(address _issuer) {
        bool isAuthorized = (_issuer == admin || authorizedAccountsMap[_issuer].isAuthorized);
        AuthorizeAttempt(_issuer, isAuthorized);
        require(isAuthorized);
        _;
    }
    
    /// @notice make sure caller is the admin of this contract
    modifier onlyAdmin(address _issuer) {
        bool isAuthorized = (_issuer == admin);
        AuthorizeAttempt(_issuer, isAuthorized);
        require(isAuthorized);
        _;
    }
   
    /// @notice makes sure badge is unique
    modifier uniqueBadge(string _name) {
        require(isUnique(_name));
        _;
    }

    function isUnique(string _name) public constant returns(bool unique) {
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_name);
        return (badgeVault.badgeHashNames.length == 0 || badgeVault.badgeHashNames[badgeVault.indexMap[badgeNameHash]] != badgeNameHash);
    }

    /// @notice checks if a badge exists by name
    modifier badgeExists(string _name) {
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_name);
        require(badgeVault.badgeHashNames.length > 0 && badgeVault.badgeHashNames[badgeVault.indexMap[badgeNameHash]] == badgeNameHash);
        _;
    }

    event BadgeCreated(
        string _name,
        address indexed _issuer
    ); 
    /// @notice create a new badge store it in the badging map 
    /// @param _description Description of the badge 
    /// @param _name name of the badge
    /// @param _image badge image
    /// @param _version badge version
    function createBadge(
        string _description, 
        string _name,
        string _image,
        string _version)     
        authorized(msg.sender) uniqueBadge(_name) public
        {   
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_name);
        uint index = badgeVault.badgeHashNames.push(badgeNameHash)-1;
        BadgeLibrary.Badge memory badge = BadgeLibrary.Badge(
            address(this), 
            _description, 
            _name,
            _image, 
            _version
        );
        badgeVault.badges[badgeNameHash] = badge;
        badgeVault.indexMap[badgeNameHash] = index;
        BadgeCreated(badge.name, badge.issuer);
    }

    event CredentialIssued(
        string _badgeName,
        address indexed _recipient
    );
    /// @notice issue a new credential to a recipient contract
    /// @param _badgeName name of the badge to issue 
    /// @param _recipient address of the holder contract
    /// @param _expires expire date (number of weeks)
    function issue(
        string _badgeName, 
        address _recipient, 
        uint _expires) 
    public authorized(msg.sender)
    {
        uint expires;
        if (_expires <= 0) {
            expires = _expires;
        } else {
            expires = now + (_expires * 1 weeks);
        }
        bytes32 _txtKey = VerifierLibrary.getCredentialTxKey(issuerContract, msg.data, nonce);
        _sendToRecipient(
            _badgeName, 
            expires, 
            _recipient, 
            _txtKey
        );
       _setNewTxt(_txtKey, _recipient, _badgeName, expires);
    }
    
    event CredentialRevoked(bytes32 _txKey);
    /// @notice revoke a credential
    function revoke(bytes32 _txKey) public authorized(msg.sender) {
        revokationMap[_txKey] = true;
        CredentialRevoked(_txKey);
    }

    event CredentialUnRevoked(bytes32 _txKey);
    /// @notice unrevoke a credential
    function unRevoke(bytes32 _txKey) public authorized(msg.sender) {
        revokationMap[_txKey] = false;
        CredentialUnRevoked(_txKey);
    }

    event NewAccountAuthorized(address _newIssuer);
    /// @notice add a new account that will be able to issue credentials from this contract
    function authorzeAccount(address _newIssuer) public onlyAdmin(msg.sender) {
        authorizedAccountsMap[_newIssuer] = AuthorizedAccount(_newIssuer, authorizedAccountsList.push(_newIssuer)-1, true);
        NewAccountAuthorized(_newIssuer);
    }

    event AuthorizedAccountRemoved(address _issuer);
    /// @notice remove an authorized issuer from this contract 
    /// @param _issuer address of the account that will be authorized
    //@TODO remove account entirely from contract
    function removeAuthorizedAccount(address _issuer) public onlyAdmin(msg.sender) {
        authorizedAccountsMap[_issuer].isAuthorized = false;
        AuthorizedAccountRemoved(_issuer);
    }

    /// @notice gets a authorized account, can be used in conjuntion with numOfAuthorizedAccounts to get all in UI
    /// @param _index the index of the account in the authorizedAccountsList
    function getAuthorizedAccount(uint _index) public returns(address _issuer) {
        if (authorizedAccountsMap[authorizedAccountsList[_index]].isAuthorized) {
            return authorizedAccountsList[_index];
        } else {
            return NONE;
        }
    }

    /// @notice returns number of accounts ever authorized 
    function getNumberOfAuthorizedAccounts() public returns(uint _numOfAccounts) {
        return authorizedAccountsList.length;
    }

    /// @notice check if credential is revoked
    function isRevoked(bytes32 _key) public constant returns(bool c) {
        return revokationMap[_key];
    }
    
    /// @notice set a new transaction (credential issued to recipient)
    /// @param _txtKey the transaction key 
    /// @param _recipient recipient of the credential 
    function _setNewTxt(
        bytes32 _txtKey, 
        address _recipient, 
        string _badgeName,
        uint _expires) private
        {
        //increase nonce
        nonce++;
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_badgeName);
        BadgeLibrary.Badge memory badge = badgeVault.badges[badgeNameHash];
        bytes32 integrityHash = VerifierLibrary.getIntegrityHash(
            badge.issuer, 
            badge.description, 
            badge.name, 
            badge.image, 
            badge.version, 
            _expires,
            _recipient 
        );
        IssueTransaction memory transaction = IssueTransaction(_txtKey, integrityHash, _recipient);
        credentialTxtMap[_txtKey] = transaction;
    }
    function getTransaction(bytes32 _txtKey) constant public returns(bytes32 txtKey, bytes32 integrityHash, address recipient) {
        IssueTransaction memory transaction = credentialTxtMap[_txtKey];
        return(
            transaction.key,
            transaction.integrityHash,
            transaction.recipient
        );
    } 

    /// @notice internal method that gets instance of recipient contract and stores credential
    function _sendToRecipient(
        string _badgeName, 
        uint expires, 
        address _recipient, 
        bytes32 _txtKey
    ) private
    {   
        BadgeLibrary.Badge memory badge = badgeVault.badges[BadgeLibrary.getBadgeNameHash(_badgeName)];
        require(badge.issuer != NONE);
        HolderInterface holder = HolderInterface(_recipient);
        holder.storeCredential(
            badge.issuer,
            badge.description,
            badge.name,
            badge.image,
            badge.version,
            expires,
            _recipient, 
            _txtKey
        );
        CredentialIssued(
            badge.name,
            _recipient
        );
    }
    
    event BadgeDeleted(string _name, uint count);
    /// @notice delete a created badge 
    function deleteBadge(string _name) 
    authorized(msg.sender)
    public returns(bool success) 
    {
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_name);
        uint rowToDelete = badgeVault.indexMap[badgeNameHash];
        bytes32 rowToMove = badgeVault.badgeHashNames[badgeVault.badgeHashNames.length-1];
        badgeVault.indexMap[rowToMove] = rowToDelete; 
        badgeVault.badgeHashNames[rowToDelete] = rowToMove; 
        badgeVault.badgeHashNames.length--;
        delete badgeVault.badges[badgeNameHash];
        delete badgeVault.indexMap[badgeNameHash];

        BadgeDeleted(_name, badgeVault.badgeHashNames.length);
        return true;
    }
 
    // @notice get the number of badges (used by frontend as iterator index to retrieve each badge)     authorized(_sig, _v, _r, _s) 
    function getNumberOfBadges()
    constant public returns(uint count)
    {   
        return badgeVault.badgeHashNames.length;
    }

    /// @notice get a badge by it's index (should be used by frontend in a loop to get all the badges)
    /// @param _name name of the badge to get inside the badge map
    function getBadge(string _name) constant badgeExists(_name) public returns(
        address issuer, 
        string description, 
        string bName, 
        string image, 
        string version
    ) {
        bytes32 badgeNameHash = BadgeLibrary.getBadgeNameHash(_name);
        BadgeLibrary.Badge memory badge = badgeVault.badges[badgeNameHash];
        return (
            badge.issuer, 
            badge.description,
            badge.name, 
            badge.image,
            badge.version
        );
    } 

    /// @notice helper function for UI to retrieve all names then retrieve the badges
    /// @param _index index of the name you want
    function getNameByIndex(uint _index) constant public returns(bytes32 _name) {
        return badgeVault.badgeHashNames[_index];
    }

    /// @notice get issuer info
    function getInfo() public constant returns(address _issuer, address _contract, string _name, string _url) {
        return(admin, issuerContract, name, url);
    }
}