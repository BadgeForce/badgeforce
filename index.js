const issuer_artifacts = require('./build/contracts/Issuer.json');
const holder_artifacts = require('./build/contracts/Holder.json');
const badgeLibrary_artifacts = require('./build/contracts/BadgeLibrary.json');
module.exports = {
    issuer: issuer_artifacts, 
    holder: holder_artifacts,
    badgeLibrary: badgeLibrary_artifacts
};