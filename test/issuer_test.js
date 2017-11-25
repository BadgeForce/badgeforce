var Issuer = artifacts.require("./Issuer.sol");
var Holder = artifacts.require("./Holder.sol");
var BadgeForceToken = artifacts.require("BadgeForceToken.sol");
const utils = require("./test-utils");

contract('Issuer', function (accounts) {

  let token; 
  let issuer;
  //create new smart contract instances before each test method
  beforeEach(async function () {
    token = await BadgeForceToken.new();
    utils.issuerInitialParams._issuer = accounts[0];
    utils.issuerInitialParams._token = token.address;
    issuer = await Issuer.new(...Object.values(utils.issuerInitialParams));
  });

  it("should set initial attributes", async function() {
    assert.equal(await issuer.admin(), utils.issuerInitialParams._issuer);
    assert.equal(await issuer.name(), utils.issuerInitialParams._name);
    assert.equal(await issuer.url(), utils.issuerInitialParams._url);
  });
  it("should return issuer info", async function() {
    const info = await issuer.getInfo();
    //address _issuer, address _contract, string _name, string _url
    assert.equal(info[0], accounts[0]);
    assert.equal(info[1], await issuer.issuerContract());
    assert.equal(info[2], utils.issuerInitialParams._name);
    assert.equal(info[3], utils.issuerInitialParams._url);
  });
  it("should retrieve number of badges", async function() {
    const numOfBadges = await issuer.getNumberOfBadges();
    assert.equal(numOfBadges, 0);
  });   
  it("should create badge and retrieve it", async function() {
    await issuer.createBadge(...Object.values(utils.createBadgeParams));
    const data = await issuer.getBadge(0);
    const badge = utils.getBadgeObj(data);
    assert.equal(badge._issuer, issuer.address);
    assert.equal(badge._description, utils.createBadgeParams._description);
    assert.equal(badge._name, utils.createBadgeParams._name);
    assert.equal(badge._image, utils.createBadgeParams._image);
    assert.equal(badge._version, utils.createBadgeParams._version);
  });
  it("should delete badge", async function() {
    await issuer.createBadge(...Object.values(utils.createBadgeParams));
    await issuer.deleteBadge(utils.createBadgeParams._name);
    const numOfBadges = await issuer.getNumberOfBadges();
    assert.equal(numOfBadges, 0);
  });
  it("should issue badge to holder", async function() {
    const holder = await Holder.new(accounts[0]);
    await holder.addTrustedIssuer(issuer.address);
    await issuer.createBadge(...Object.values(utils.createBadgeParams));
    //string _badgeName, address _recipient, uint _expires
    const issueParams = {
      _badgeName: utils.createBadgeParams._name,
      _recipient: holder.address,
      _expires: 0,
    }
    await issuer.issue(...Object.values(issueParams));
    const data = await holder.getCredential(0);
    const credential = utils.getCredentialObj(data);
    assert.equal(credential._name, issueParams._badgeName);
    assert.equal(credential._recipient, issueParams._recipient);

    //bytes32 key; bytes32 integrityHash; address recipient;
    const issueTransaction = await issuer.credentialTxtMap(credential._txKey);
    assert.equal(issueTransaction[2], credential._recipient);
  }); 
  it("should revoke and unrevoke a credential", async function() {
    const holder = await Holder.new(accounts[0]);
    await holder.addTrustedIssuer(issuer.address);
    await issuer.createBadge(...Object.values(utils.createBadgeParams));
    //string _badgeName, address _recipient, uint _expires
    const issueParams = {
      _badgeName: utils.createBadgeParams._name,
      _recipient: holder.address,
      _expires: 0,
    }
    await issuer.issue(...Object.values(issueParams));
    const data = await holder.getCredential(0);
    const credential = utils.getCredentialObj(data);
    await issuer.revoke(credential._txKey);
    let revoked = await issuer.revokationMap(credential._txKey);
    assert.equal(revoked, true);
    await issuer.unRevoke(credential._txKey);
    revoked = await issuer.revokationMap(credential._txKey);
    assert.equal(revoked, false);
  });
  it("should add new authorized account and unauthorize account", async function() {
    issuer.authorzeAccount(accounts[1]);
    let account = await issuer.authorizedAccountsMap(accounts[1]);
    assert.equal(account[0], accounts[1]);
    assert.equal(account[2], true);
    issuer.removeAuthorizedAccount(accounts[1]);
    account = await issuer.authorizedAccountsMap(accounts[1]);
    assert.equal(account[2], false);    
  });
});