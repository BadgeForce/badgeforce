pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Issuer.sol";

contract TestIssuer {
  
  Issuer issuer = Issuer(DeployedAddresses.Issuer());

  function testGetNumberOfBadges() {
    Assert.equal(issuer.getNumberOfBadges(), 0, "Issuer should have 0 badges");
  }

  /*function testGetInfo() {
    address expectedIssuerAddress = issuer.issuer();
    address expectedIssuerContractAddress = address(issuer);
    string expectedName = issuer.name(); 
    string expectedUrl = issuer.url(); 

    var (_issuer, _contract, _name, _url) = issuer.getInfo();
    Assert.equal(expectedIssuerAddress, _issuer, "Issuer Address from getInfo should be the same");
    Assert.equal(expectedIssuerContractAddress, _contract, "Contract Address from getInfo should be the same");
    Assert.equal(expectedName, _name, "Name from getInfo should be the same");
    Assert.equal(expectedUrl, _url, "Url from getInfo should be the same");
  }*/

  function testGetBadge() {
    issuer.getBadge(0);
  }
  function testAddBadge() {
    issuer.addBadge();
  }

}
