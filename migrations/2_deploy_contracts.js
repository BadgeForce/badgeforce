var Issuer = artifacts.require("../contracts/Issuer.sol");
var Holder = artifacts.require("../contracts/Holder.sol");
var BadgeLibrary = artifacts.require("BadgeLibrary.sol");

module.exports = function (deployer) {
  deployer.deploy([BadgeLibrary]);
  deployer.link(BadgeLibrary,[Issuer, Holder]);  
  deployer.deploy(Issuer, '0x22b718c22b2f21c849d5afb5002033aefc81184b', "Khalil Claybon", "https://github.com/kc1116");
  deployer.deploy(Holder, '0x22b718c22b2f21c849d5afb5002033aefc81184b');
}; 

/*
Issuer.deployed().then(function(c){c.createBadge("This person loves Golang", "GoAdvocate", "image", "1.0", "json").then(console.log).catch(console.error)})
Issuer.deployed().then(function(c){c.issue("GoAdvocate",'0xb2e15fb9a726f92c8c338c5ac98c5c11a76c31c4', 0).then(console.log).catch(console.error)})

Issuer.deployed().then(function(c){c.createBadge().then(console.log).catch(console.error)})
Issuer.deployed().then(function(c){c.issuer.call().then(console.log)})
Issuer.deployed().then(function(c){c._getTxtKey('data').then(console.log)})
Issuer.deployed().then(function(c){c._setNewTxt('0xaf47454c80c89ee3bd0e9552cf1ec68429f00f140e4c8f5bfb2a3b9061840250', '0x013f4c49c53ad38eb03d29b16b28e2ec54e404aa').then(console.log)})
Issuer.deployed().then(function(c){c.badges.call().then(function(badges){console.log(badges)})})
Issuer.deployed().then(function(c){c.credentialTxMap.call().then(function(badges){console.log(badges)})})
Issuer.deployed().then(function(c){c.testAddr.call().then(console.log)})
Issuer.deployed().then(function(c){c.testHolder('0x189388fb9840f37607bb57b15563c604ccfebfb0').then(console.log)})
Issuer.deployed().then(function(c){c.getNumberOfBadges.call().then(console.log)})
Issuer.deployed().then(function(c){c.issuer.call(0).then(function(issuer){console.log(issuer == '0xac44f6c7b0def0f11a4a687fb4ddf78fd68d2f83')})})
Issuer.deployed().then(cosole.log)

Issuer.deployed().then(function(c){c.getRevoked('0x119c859ffd7a9f4b24455093b7ec9061e97bde01bf8ff15e31cec74c4ce31cae').then(console.log).catch(console.log)})
Issuer.deployed().then(function(c){c.credentialTxtMap(0).then(console.log).catch(console.log)})
Issuer.deployed().then(function(c){c._getTxt('0x2f077e95a6cb654aebe902c3f0ecacc8208ae99e78fe04c9020428b2c063752d').then(console.log)})


Holder.deployed().then(function(c){c.getBadge(0).then(console.log).catch(console.log)})
Holder.deployed().then(function(c){c.verifyCredential(0).then(console.log).catch(console.log)})
Holder.deployed().then(function(c){c.addTrustedIssuer('0x47205ce9b1fad62a143e58adb463524e73bc2a42').then(console.log).catch(console.log)})


web3.eth.sendTransaction({to:0xfcc6c152a8d7dec89b54eab85c2ce634f9a48177, from:0x86e61595210f80e073ecb859fdf39b7400000000, data: getData});*/

//Issuer.deployed().then(function(c){c.testHolder('0x189388fb9840f37607bb57b15563c604ccfebfb0').then(console.log).catch(console.error)})
