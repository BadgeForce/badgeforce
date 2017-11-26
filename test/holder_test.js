var Issuer = artifacts.require("./Issuer.sol");
var Holder = artifacts.require("./Holder.sol");
var BadgeForceToken = artifacts.require("BadgeForceToken.sol");
const utils = require("./test-utils");

contract('Holder', function (accounts) {
    let token; 
    let holder;
    let issuer;
    //create new smart contract instances before each test method
    beforeEach(async function () {
      token = await BadgeForceToken.new();
      utils.issuerInitialParams._issuer = accounts[0];
      utils.issuerInitialParams._token = token.address;
      issuer = await Issuer.new(...Object.values(utils.issuerInitialParams));
      holder = await Holder.new(accounts[0]);
    });
    it("should add and remove trusted issuer", async function() {
        await holder.addTrustedIssuer(issuer.address);
        let trusted = await holder.trustedIssuers(issuer.address);
        assert.equal(trusted, true);

        await holder.removeTrustedIssuer(issuer.address);
        trusted = await holder.trustedIssuers(issuer.address);
        assert.equal(trusted, false);
    });  
    it("should get number of credentials", async function() {
        const count = await holder.getNumberOfCredentials();
        assert.equal(count, 0);
    });
    it("should get a credential and verify (true, false if revoked)", async function() {
        await issuer.createBadge(...Object.values(utils.createBadgeParams));
        await holder.addTrustedIssuer(issuer.address);
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
        let response = await holder.verifyCredential(0);
        assert.equal(response[0], true);
        await issuer.revoke(credential._txKey);
        response = await holder.verifyCredential(0);
        assert.equal(response[0], false);
    });
});