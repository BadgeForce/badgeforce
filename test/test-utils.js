//initial params for testing address _issuer, string _name, string _url, address _token
const issuerInitialParams = {
  _issuer: 0x0,
  _name: "BadgeForce",
  _url: "https://github.com/BadgeForce",
  _token: 0x0,
  _verifier:0x0
};

//string _description, string _name,string _image,string _version, string _json
const createBadgeParams = {
    _description: "This badge is super cool",
    _name: "Cool badge",
    _image: "http://some/image/url",
    _version: "1"
}

const getCredentialObj = (data) => {
    let credential = {};
    ({0:credential._issuer, 1:credential._description, 2:credential._name, 3:credential._image, 
        4:credential._version, 5:credential._expires, 6:credential._recipient, 7: credential._txKey} = data);
    return credential;
}

const getBadgeObj = (data) => {
    let badge = {};
    ({0:badge._issuer, 1:badge._description, 2:badge._name, 3:badge._image, 4:badge._version} = data);
    return badge;
}

module.exports = {
    issuerInitialParams, 
    createBadgeParams,
    getCredentialObj,
    getBadgeObj
}