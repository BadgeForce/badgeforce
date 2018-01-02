pragma solidity ^0.4.17;

import "BadgeLibrary/contracts/BadgeLibrary.sol";

import "./AuthorizedIssuer.sol";

contract BadgeManager is AuthorizedIssuer {
    
    /// @notice mapping of badgename hash to badge
    /// @notice array of badge hash names
    struct Vault {
        mapping (bytes32=>BadgeLibrary.Badge) badges;
        mapping (bytes32=>uint) indexMap;
        bytes32[] badgeHashNames;
    }

    /// @notice storage for earnable badges 
    Vault badgeVault;

    function BadgeManager(address _adminWalletAddr) public AuthorizedIssuer(_adminWalletAddr) {}

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

}