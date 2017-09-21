import axios from "axios";

export const mecsCsvFieldMapping = {
    "SalesForce_Account_Id": "salesForceAccountId",
    "Account_Name": "accountName",
    "franchiseLocationId": "franchiseLocationId",
    "Business_Name": "businessName",
    "First": "firstName",
    "Last": "lastName",
    "Email": "email",
    "Primary_Phone": "phone",
    "Existing_Domain": "existingDomain",
    "Address_1": "street1",
    "Address_2": "street2",
    "City": "city",
    "State": "state",
    "Zip": "zip",
};

const mecs = "https://apirouter.yd-api.com";
export const bulkCreation = "/v1/mecs/create-accounts";
export const validation = "/v1/mecs/validate";
const salesReps = "/v1/mecs/salesreps";

export const getObjectWithMecsFields = (obj) => {
    const transformed = {};
    for (const key of Object.keys(mecsCsvFieldMapping)) {
        const newFieldName = mecsCsvFieldMapping[key];
        transformed[newFieldName] = obj[key];
    }
    return transformed;
};

const copy = (obj) => {
    return JSON.parse(JSON.stringify(obj));
};

export const getPostString = (formData, csv) => {
    const csvCopy = copy(csv);
    const transformedCsv = csvCopy.map((rowData) => {
        return getObjectWithMecsFields(rowData);
    });

    const postObj = {
        corporateConfig: formData,
        clientData: transformedCsv,
    };
    return JSON.stringify(postObj, null, 4);
};

const getFormData = (data) => {
    return {
        corporateRelationshipId: data.corpAccntNum,
        salesRepId: data.salesRep,
        segment: data.segment,
        clientHosted: data.clientHosted,
        sponsored: data.sponsored,
        centerMark: data.centerMark,
        centerMarkLite: data.centerMarkLite,
        sponsoredSetup: data.sponsoredSetup,
        yodleWeb: data.yodleWeb,
        yodleWebMonthly: data.yodleWebMonthly,
        centerMarkMonthly: data.centerMarkMonthly,
        centerMarkSetup: data.centerMarkSetup,
        centerMarkLiteMonthly: data.centerMarkLiteMonthly,
        centerMarkLiteSetup: data.centerMarkLiteSetup,
        country: data.country,
        mobile: data.mobile,
    };
};

export const mecsPost = (endpoint, data) => {
    return axios({
        method: "post",
        url: mecs + endpoint,
        data: getPostString(getFormData(data), data.csvData),
        headers: {
            "Content-Type": "application/json",
        },
    });
};

export const createAccounts = (data) => {
    return mecsPost(bulkCreation, data);
};

export const validateAccountData = (data) => {
    return mecsPost(validation, data);
};

export const getSalesReps = () => {
    return axios.get(mecs + salesReps);
};