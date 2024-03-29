var Issuer = artifacts.require("../contracts/Issuer.sol");
var Holder = artifacts.require("../contracts/Holder.sol");
var BadgeManager = artifacts.require("../contracts/BadgeManager.sol");
var Verifier = artifacts.require("../contracts/Verifier.sol");
var TransactionManager = artifacts.require("../contracts/TransactionManager.sol");
var BadgeLibrary = artifacts.require("BadgeLibrary.sol");
var BadgeForceToken = artifacts.require("BadgeForceToken.sol");

module.exports = function (deployer) {
  //linked for testing purposes
  deployer.deploy([BadgeLibrary]);
  deployer.link(BadgeLibrary,[Issuer, Holder, BadgeManager, TransactionManager, Verifier]);  
  deployer.deploy(Issuer, '0xee2845a3452459f4ec8b114cead11a8c5b01dca9', "BadgeForce Engineering", "https://github.com/badgeforce", "0x287c90b1c520324e2ad33314936ac62d192704a6");
  deployer.deploy(Holder, '0xdb069e4181f4a44ef78aa4486d19be49d2e9e8f2');
}; 

