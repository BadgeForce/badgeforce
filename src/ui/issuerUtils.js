import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'
import { default as Promise} from 'bluebird';
import issuer_artifacts from '../../build/contracts/Issuer.json'
var Issuer = contract(issuer_artifacts);

const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
Issuer.setProvider(web3.currentProvider);

export const getIssuerInfo = (resolve, reject) => {
    Promise.all([getIssuerName(), getIssuerUrl(), getIssuerAddress(), getBadges()]).spread(resolve, reject).done();
};

export const getIssuerName = () => {
    return Issuer.deployed().then((c) => {
        return c.name.call().then(name => {
            return name;
        });
    })
}

export const getIssuerUrl = () => {
    return Issuer.deployed().then((c) => {
        return c.url.call().then(url => {
            return url;
        });
    })
}

export const getIssuerAddress = () => {
    return Issuer.deployed().then((c) => {
        return c.issuer.call().then(issuer => {
            return issuer;
        });
    })
}

export const getBadges = () => {
    return getNumberOfBadges().then(count => {
        let promises = [];
        for (let i = 0; i < count; i++) {
            promises.push(getBadge(i));
        }

        return Promise.reduce(promises, (result, badge) => {
            result.push(badge);
            return result;
        }, [])      // Initial value
        .then(badges => {
            return badges;
        })
    })
}

export const getNumberOfBadges = () => {
    return Issuer.deployed().then((c) => {
        return c.numberOfBadges.call().then(badgeCount => {
            return badgeCount;
        });
    })
}

export const getBadge = (i) => {
    return Issuer.deployed().then((c) => {
        return c.badges.call(i).then(badge => {
            return badge;
        });
    })
}