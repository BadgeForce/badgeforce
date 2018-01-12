const issuer_artifacts = require('./build/contracts/Issuer.json');
const holder_artifacts = require('./build/contracts/Holder.json');
const badgeLibrary_artifacts = require('./build/contracts/BadgeLibrary.json');
const badgeManager_artifacts = require('./build/contracts/BadgeManager.json');
const authorizedIssuer_artifacts = require('./build/contracts/AuthorizedIssuer.json');
const transactionManager_artifacts = require('./build/contracts/TransactionManager.json');
const verifier_artifacts = require('./build/contracts/Verifier.json');

module.exports = {
    issuer: issuer_artifacts,
    holder: holder_artifacts,
    badgeLibrary: badgeLibrary_artifacts:
    badgeManager_artifacts: badgeManager_artifacts,
    authorizedIssuer_artifacts: authorizedIssuer_artifacts,
    transactionManager_artifacts: transactionManager_artifacts,
    verifier_artifacts: verifier_artifacts
};
