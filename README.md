# badgeforce
Solidity Smart contracts for Issuers and Holders. 

## Install Dependecies 

We are using [truffle]() and [testrpc]() for our smart contract development

Install testrpc and truffle 
```linux
$ npm install -g testrpc
$ npm install -g truffle
```

Install project dependencies
```linux
$ npm install
```

## Run Test

Start your Ethereum testrpc node you might have to alter gas limit, we have seem differences on different OS
```linux
$ testrpc -l 4500000000000 --network-id 3000 --port 8000
```

Next cd into badgeforce cloned directory and run test, make sure dependencies are installed
```linux
$ truffle test
```

## Usage 

Usage examples are in JavaScript using [web3]() and [truffle]()
* [Issuer](#Issuer)
    * [admin](admin)
    * [authorizedAccountsMap](authorizedAccountsMap)
    * [getInfo](getInfo)
    * [createBadge](createBadge)
    * [deleteBadge](deleteBadge)
    * [getNumberOfBadges](getNumberOfBadges)
    * [getBadge](getBadge)
    * [issue](issue)
    * [revoke](revoke)
    * [unRevoke](unRevoke)
    * [getRevoked](getRevoked)
    * [authorzeAccount](authorzeAccount)
    * [removeAuthorizedAccount](removeAuthorizedAccount)
    * [getAuthorizedAccount](getAuthorizedAccount)
    * [getNumberOfAuthorizedAccounts](getNumberOfAuthorizedAccounts)