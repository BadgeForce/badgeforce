import validator from "validator";
import _ from "lodash";

const SalesForceAccountId_Regex = new RegExp(/^001([a-zA-Z0-9]+)/);
const PrimaryPhone_Regex = new RegExp(/^\d{10}$/);
const ExistingDomain_Regex = new RegExp(/^(?!www\.)[a-z0-9\-]{2,50}\.([a-z]{2,15})/i);
const Zip_Regex = new RegExp(/(^\d{5}[ -]*(\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1}[ -]*\d{1}[A-Z]{1}\d{1}$)/);

const CorporateRelationshipID_Regex = new RegExp(/^\d{3}|\d{10}$/);
const SalesRepId_Regex = new RegExp(/^[0-9]+$/);

const VALID = { valid: true, error: null };

const ERRORS = {
    "SalesForce_Account_Id": "SalesForce Account Id cannot be left empty, must start with 001 and be followed by only letters and numbers",
    "Account_Name": "Account Name cannot be left empty and must be a min 2 characters",
    "Business_Name": "Business Name cannot be left empty and must be between 2 and 99 characters long",
    "First": "First name cannot be left empty and must be between 2 and 255 characters long",
    "Last": "Last name cannot be left empty and must be between 2 and 255 characters long",
    "Primary_Phone": "Primary Phone cannot be left empty and must be a valid phone number",
    "Email": "Email cannot be left empty and must be a valid email",
    "Existing_Domain": "Existing Domain must be properly formatted url i.e: yodle.com",
    "Address_1": "Address_1 cannot be left empty and must be between 2-75 characters long",
    "Address_2": "Address_2 must be max 75 characters",
    "City": "City cannot be left empty and must be between 3 and 45 characters long",
    "State": "State cannot be left empty and must be State abbreviation",
    "Zip": "Invalid zipcode",
    "CorpRelId": "Corporate Account Number cannot be left empty and must be 3 digits",
    "Country": "Country must either be US or CA",
    "Segment": "Segment cannot be left empty",
    "NonNegative": "Amount must be greater than 0",
    "YodleWeb": "Yodle Web cannot be provisioned with CenterMark",
    "CenterMarkLite": "CenterMarkLite cannot be provisioned with CenterMark",
    "ChooseSalesRep": "You must choose a Sales Rep",
};

const getInvalidRes = (prop) => {
    return { valid: false, error: ERRORS[prop] };
};

const validatorMap = {
    "franchiseLocationId": () => {
        return null;
    },
    "SalesForce_Account_Id": (salesForceAccountId) => {
        if (!SalesForceAccountId_Regex.test(salesForceAccountId)) return ERRORS.SalesForce_Account_Id;
        return null;
    },
    "Account_Name": (accountName) => {
        if (accountName.length < 2) return ERRORS.Account_Name;
        return null;
    },
    "Business_Name": (businessName) => {
        if (businessName.length < 2 || businessName.length > 99) return ERRORS.Business_Name;
        return null;
    },
    "First": (firstName) => {
        if (firstName.length < 2 || firstName.length > 255) return ERRORS.First;
        return null;
    },
    "Last": (lastName) => {
        if (lastName.length < 2 || lastName.length > 255) return ERRORS.Last;
        return null;
    },
    "Primary_Phone": (primaryPhone) => {
        if (!PrimaryPhone_Regex.test(primaryPhone)) return ERRORS.Primary_Phone;
        return null;
    },
    "Email": (email) => {
        if (!validator.isEmail(email)) return ERRORS.Email;
        return null;
    },
    "Existing_Domain": (existingDomain) => {
        if (existingDomain === "") return null;
        if (!ExistingDomain_Regex.test(existingDomain)) return ERRORS.Existing_Domain;
        return null;
    },
    "Address_1": (address) => {
        if (address.length < 2 || address.legnth > 75) return ERRORS.Address_1;
        return null;
    },
    "Address_2": (address) => {
        if (address.length > 75) return ERRORS.Address_2;
        return null;
    },
    "City": (city) => {
        if (city.length < 3 || city.legnth > 45) return ERRORS.City;
        return null;
    },
    "State": (state) => {
        if (state.length < 2 || state.length > 3) return ERRORS.State;
        return null;
    },
    "Zip": (zipCode) => {
        if (!Zip_Regex.test(zipCode)) return ERRORS.Zip;
        return null;
    },
};

const validateCSVEntry = (data, rowNumber, emailCache) => {
    const errorMap = {
        errors: [],
        row: rowNumber,
    };

    _.forEach(data, (value, key) => {
        const error = validatorMap[key](value);
        if (error !== null) errorMap.errors.push({ key, error });
    });
    if (emailCache[data.Email]) errorMap.errors.push({ key: "DuplicateEmail", value: `Duplicate email address ${ data.Email }` });
    if (errorMap.errors.length > 0) return errorMap;
    return null;
};

const validateCSV = (csvData) => {
    let rowNumber = 1;
    const emailCache = {};
    const errors = [];
    _.forEach(csvData, (data) => {
        const error = validateCSVEntry(data, rowNumber, emailCache);
        if (error !== null) errors.push(error);
        rowNumber++;
        emailCache[data.Email] = true;
    });
    return errors;
};

const isCorpRelId = (id) => {
    if (!CorporateRelationshipID_Regex.test(id)) {
        return getInvalidRes("CorpRelId");
    }

    return VALID;
};

const isCountry = (country) => {
    if (country.toUpperCase() !== "US" && country.toUpperCase() !== "CA") {
        return getInvalidRes("Country");
    }
    return VALID;
};

const isSalesRepId = (id) => {
    return SalesRepId_Regex.test(id);
};

const isSegment = (segment) => {
    if (segment === "") {
        return getInvalidRes("Segment");
    }
    return VALID;
};

const isNonNegative = (data) => {
    if (!validator.isInt(String(data), { gt: -1 })) {
        return getInvalidRes("NonNegative");
    }
    return VALID;
};

const validateFormDataOptions = (data) => {
    const check = { valid: true, errors: [] };
    if (data.centerMark && data.yodleWeb) check.errors.push(ERRORS.YodleWeb);

    if (data.centerMark && data.centerMarkLite) check.errors.push(ERRORS.CenterMarkLite);

    if (data.salesRep === "") check.errors.push(ERRORS.ChooseSalesRep);

    let err = isNonNegative(data.centerMarkMonthly).error;
    err !== null ? check.errors.push(err) : null;

    err = isNonNegative(data.sponsoredSetup).error;
    err !== null ? check.errors.push(err) : null;

    err = isNonNegative(data.centerMarkSetup).error;
    err !== null ? check.errors.push(err) : null;

    err = isNonNegative(data.centerMarkLiteMonthly).error;
    err !== null ? check.errors.push(err) : null;

    err = isNonNegative(data.centerMarkLiteSetup).error;
    err !== null ? check.errors.push(err) : null;

    err = isNonNegative(data.yodleWebMonthly).error;
    err !== null ? check.errors.push(err) : null;

    if (check.errors.length > 0) check.valid = false;
    return check;
};

export { validateCSV, isCorpRelId, isCountry, isSalesRepId, isSegment, validateFormDataOptions, isNonNegative, ERRORS, validatorMap };