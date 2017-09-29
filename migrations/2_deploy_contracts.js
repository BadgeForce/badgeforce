var Issuer = artifacts.require("../contracts/Issuer.sol");
var Holder = artifacts.require("../contracts/Holder.sol");
var BadgeLibrary = artifacts.require("../contracts/BadgeLibrary.sol");

module.exports = function (deployer) {
  deployer.deploy([BadgeLibrary]);
  deployer.link(BadgeLibrary,[Issuer, Holder]);  
  deployer.deploy(Issuer, '0xdb57ffa153af4a8dc058b7d6c6c995defdb9b5ff', "Khalil Claybon", "https://github.com/kc1116");
  deployer.deploy(Holder, '0xdb57ffa153af4a8dc058b7d6c6c995defdb9b5ff');
}; 

/*
Issuer.deployed().then(function(c){c.createBadge("This person loves Golang", "GoAdvocate", "image", "1.0", "json").then(console.log).catch(console.error)})
Issuer.deployed().then(function(c){c.issue("GoAdvocate",'0x4c370b35d5068e6f1d17085c74b0061fa381998b', 0).then(console.log).catch(console.error)})

Issuer.deployed().then(function(c){c.createBadge().then(console.log).catch(console.error)})
Issuer.deployed().then(function(c){c.issuer.call().then(console.log)})
Issuer.deployed().then(function(c){c._getTxtKey('data').then(console.log)})
Issuer.deployed().then(function(c){c._setNewTxt('0xaf47454c80c89ee3bd0e9552cf1ec68429f00f140e4c8f5bfb2a3b9061840250', '0x013f4c49c53ad38eb03d29b16b28e2ec54e404aa').then(console.log)})
Issuer.deployed().then(function(c){c.badges.call().then(function(badges){console.log(badges)})})
Issuer.deployed().then(function(c){c.credentialTxMap.call().then(function(badges){console.log(badges)})})
Issuer.deployed().then(function(c){c.testAddr.call().then(console.log)})
Issuer.deployed().then(function(c){c.testHolder('0x189388fb9840f37607bb57b15563c604ccfebfb0').then(console.log)})
Issuer.deployed().then(function(c){c.numberOfBadges.call().then(console.log)})
Issuer.deployed().then(function(c){c.issuer.call(0).then(function(issuer){console.log(issuer == '0xac44f6c7b0def0f11a4a687fb4ddf78fd68d2f83')})})
Issuer.deployed().then(cosole.log)

Issuer.deployed().then(function(c){c.credentialTxtMap(0).then(console.log).catch(console.log)})
Issuer.deployed().then(function(c){c._getTxt('0x2f077e95a6cb654aebe902c3f0ecacc8208ae99e78fe04c9020428b2c063752d').then(console.log)})


Holder.deployed().then(function(c){c.getBadge().then(console.log).catch(console.log)})
Holder.deployed().then(function(c){c.addTrustedIssuer('0x2115f107ec05434192499f36605786c922c1b7bb').then(console.log).catch(console.log)})


web3.eth.sendTransaction({to:0xfcc6c152a8d7dec89b54eab85c2ce634f9a48177, from:0x86e61595210f80e073ecb859fdf39b7400000000, data: getData});*/

//Issuer.deployed().then(function(c){c.testHolder('0x189388fb9840f37607bb57b15563c604ccfebfb0').then(console.log).catch(console.error)})
