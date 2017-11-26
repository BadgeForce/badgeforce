var Issuer = artifacts.require("../contracts/Issuer.sol");
var Holder = artifacts.require("../contracts/Holder.sol");
var BadgeLibrary = artifacts.require("BadgeLibrary.sol");
var BadgeForceToken = artifacts.require("BadgeForceToken.sol");
var PaymentLibrary = artifacts.require("PaymentLibrary.sol");

module.exports = function (deployer) {
  //deployed for testing purposes
  deployer.deploy([PaymentLibrary]);
  //linked for testing purposes
  deployer.link(PaymentLibrary,[BadgeForceToken]);

  deployer.deploy([BadgeLibrary]);
  deployer.link(BadgeLibrary,[Issuer, Holder]);  
  deployer.deploy(Issuer, '0x49b4866f12ad338053f6da4c03b10e82d8d29d89', "BadgeForce Engineering", "https://github.com/badgeforce", "0x287c90b1c520324e2ad33314936ac62d192704a6");
  deployer.deploy(Holder, '0xdb069e4181f4a44ef78aa4486d19be49d2e9e8f2');
}; 

