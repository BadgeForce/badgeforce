var Issuer = artifacts.require("./Issuer.sol");
var Holder = artifacts.require("./Holder.sol");
var BadgeForceToken = artifacts.require("BadgeForceToken.sol");
const utils = require("./test-utils");

contract('Holder', function (accounts) {
    let token; 
    let issuer;
    let holder;
    //create new smart contract instances before each test method
    beforeEach(async function () {
        token = await BadgeForceToken.new();
        utils.issuerInitialParams._adminWalletAddr = accounts[0];
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
    it("should get a credential", async function() {
        await utils.issueCredential(issuer, holder);
        const key = await holder.getTxnKey(0);
        const credential = utils.getCredentialObj((await holder.getCredential(key)));
        assert.equal(credential._name, utils.createBadgeParams._name);
    });
    it("should delete a credential", async function() {
        await utils.issueCredential(issuer, holder);
        await holder.deleteCredential(utils.createBadgeParams._name);

        const count = await holder.getNumberOfCredentials();
        assert.equal(count, 0);
    });
    it("should recompute correct proof of integrity hash", async function() {
        await utils.issueCredential(issuer, holder);
        const key = await holder.getTxnKey(0);
        const credential = utils.getCredentialObj((await holder.getCredential(key)));
        const txn = utils.getTxn((await issuer.getTxn(credential._txKey)));
        const hash = await holder.recomputePOIHash(credential._txKey);
        assert.equal(txn._integrityHash, hash);
    });
});