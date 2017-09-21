pragma solidity ^0.4.15;


library BadgeLibrary {

    /// @notice represents simple details about a earnable badge
    struct BFBadge {
        address issuer;
        string description;
        string name;
        string image;
        uint version; 
        string json;
    }    

    /// @notice represents details of an issued badge 
    struct BFCredential {
        address issuer;
        string description;
        string name;
        string image;
        uint version; 
        string json;
        bool revoked;
        uint expires;
        address recipient;
        bytes32 txKey;
    }

    function credentialTxKey(address _issuer, bytes _msgData, uint _nonce) constant public returns(bytes32 key) {
        return sha3(_issuer, _msgData, _nonce);
    }

    function getBadgeNameHash(string _badgename) constant public returns (bytes32 _hash) {
        return sha3(_badgename);
    }

    function getIntegrityHash(
        address _issuer, 
        string _description, 
        string _name, 
        string _image, 
        uint256 _version, 
        address _recipient
    ) constant public returns(bytes32 _hash) 
    {
        return bytes32(
            sha3(
                _issuer, 
                _description, 
                _name, 
                _image, 
                _version, 
                _recipient
        ));
    }

}