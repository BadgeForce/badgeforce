# badgeforce
Solidity Smart contracts for Issuers and Holders. 

## Install Dependecies 

We are using [truffle](https://truffleframework.com) and [ganache-cli](https://github.com/trufflesuite/ganache-cli) for our smart contract development

Install testrpc and truffle 
```linux
$ npm install -g testrpc
$ npm install -g ganache-cli
```

Install project dependencies
```linux
$ npm install
```

## Run Test

Start your Ethereum ganache node you might have to alter gas limit, we have seem differences on different OS
```linux
$ ganache-cli -l 4500000000000 --network-id 3000 --port 8000
```

Next cd into badgeforce cloned directory and run test, make sure dependencies are installed
```linux
$ truffle test
```

## Usage 

Usage examples are in JavaScript using [web3](https://github.com/ethereum/web3.js/) and [truffle](https://truffleframework.com)
* [Issuer](#Issuer)
    * [admin](#admin)
    * [getAuthorizedAccount](#getauthorizedaccount)
    * [authorzeAccount](#authorzeaccount)
    * [removeAuthorizedAccount](#removeauthorizedaccount)
    * [getNumberOfAuthorizedAccounts](#getnumberofauthorizedaccounts)
    * [getInfo](#getinfo)
    * [createBadge](#createbadge)
    * [deleteBadge](#deletebadge)
    * [getNumberOfBadges](#getnumberofbadges)
    * [getBadge](#getbadge)
    * [issue](#issue)
    * [revoke](#revoke)
    * [unRevoke](#unrevoke)
    * [isRevoked](#isrevoked)

***

#### admin

Automatic getter function generated for admin property on Issuer smart contract. Admin acts as God account and has special access to methods.

##### Returns

`adminAddress` 

##### Example

```js
const adminAddress = await issuer.admin();
```

***

#### getAuthorizedAccount

Function returns info for a authorized account 

##### Parameters

1. `address` - the address of the authorized issuer account you want to retrieve

##### Returns

`AuthorizedAccount` 

##### Example using authorizedAccountsMap property

```js
const authorizedAccountData = await issuer.authorizedAccountsMap(0x0000);
```

##### Example using getAuthorizedAccount method

```js
const authorizedAccountData = await issuer.getAuthorizedAccount(0x0000);
```

***

#### authorzeAccount

Function sets new authorized account. Use this function to add any enable
new ethereum wallets to issue from your Issuer smart contract. 

##### Parameters

1. `address` - the address of the issuer account you want to authorize

##### Example

```js
await issuer.authorzeAccount(0x0000);
```

***

#### removeAuthorizedAccount

Function removes an authorized account. Once an account is unauthorized the issuer that ethereum account belongs to will no longer be able to call methods with authorized modifier 

##### Parameters

1. `address` - the address of the authorized issuer account you want to unauthorize

##### Example

```js
await issuer.removeAuthorizedAccount(0x0000);
```

***

#### getNumberOfAuthorizedAccounts

Function gets the number of authorized accounts. A UI client or API interacting with an Issuer smart contract can use this function in conjunction with the [getAuthorizedAccount](#getAuthorizedAccount) method to retrieve all accounts authorized on the contract

##### Example

```js
const count = await issuer.getNumberOfAuthorizedAccounts();
```

***

#### getInfo 

Function returns information about the issuer and smart contract

##### Returns

1. `address` - the admin address on this contract
2. `address` - the address of the issuer contract it's self
3. `string` - name of the issuer
2. `string` - url associated with the issuer

##### Example

```js
const info = await issuer.getInfo();
``` 

*** 

#### createBadge

Function is used to create a new badge. This method will be extended to hold more data and more types of badges as the BadgeLibrary is further developed. 

##### Parameters

1. `string` - description of the badge 
2. `string` - name of the badge 
3. `string` - image url 
4. `string` - badge version 
5. `string` - json

##### Example

```js
const createBadgeParams = {
    _description: "This badge is super cool",
    _name: "Cool badge",
    _image: "http://some/image/url",
    _version: "1",
    _json: "json"
}
await issuer.createBadge(...Object.values(createBadgeParams));
``` 

*** 

#### deleteBadge

Function is used to delete a badge.

##### Parameters

1. `string` - name of the badge to delete

##### Example

```js
await issuer.deleteBadge(name);
``` 

***

#### getNumberOfBadges

Function is used to get the number of badges. A UI client or API interacting with an Issuer smart contract can use this function in conjunction with the [getBadge](#getBadge) method to retrieve all badges 

##### Example

```js
const count = await issuer.getNumberOfBadges();
``` 

***

#### getBadge

Function is used to get a badge. 

##### Parameters

1. `uint` - badge index 

##### Example

```js
const badge = await issuer.getBadge(index);
``` 

***

#### issue

Function is used to issue a credential to a holder contract. 

##### Parameters

1. `string` - name of a badge that already exists on the issuer smart contract
2. `address` - address of the holder contract to issue credential to 
3. `uint` - unix timstamp for expiration date or 0 for non expiring

##### Example

```js
const issueParams = {
    _badgeName: "Fresh New Badge",
    _recipient: 0x0,
    _expires: 0,
}
await issuer.issue(...Object.values(issueParams));
``` 

***

#### revoke

Function is used to revoke a badge. Once a credential is revoked it will fail verification.

##### Parameters

1. `bytes32` - transaction key of the credential to revoke

##### Example

```js
await issuer.revoke(credential._txKey);
``` 

***

#### unRevoke

Function is used to un-revoke a credential. Can be used if a credential is revoked on error. 

##### Parameters

1. `bytes32` - transaction key of the credential to revoke 

##### Example

```js
await issuer.unRevoke(credential._txKey);
``` 

***

#### isRevoked

Function is used to check if a credential is revoked. 

##### Parameters

1. `bytes32` - transaction key of the credential to check 

##### Example

```js
const check = await issuer.isRevoked(redential._txKey);
``` 

***