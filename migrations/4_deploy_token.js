const BadgeForceToken = artifacts.require(`./BadgeForceToken.sol`)

module.exports = (deployer) => {
  deployer.deploy(BadgeForceToken, 6500000000000000, "BadgeForceToken", 8, "BFC");
}

/*

token.transfer('0x8d9624db5e1fdd84194cbc005de09203a12af223', 10).then(function(data){console.log})
BadgeForceToken.deployed().then(function(token){token.transfer('0x14dc220170ad8d6a2928b5bf956e3092d56f98ee', 300000000).then(function(data){console.log})})
BadgeForceToken.deployed().then(function(token){token.createBadgePayment('0x1ce4fcefee0a70a7cf5dced5bd42f8976c7db49b').then(function(data){console.log})})

*/