import * as validator from "../validators";
import _ from "lodash";

describe("validators tests", () => {
    it("should return error for negative number", () => {
        const num = -23;
        const error = validator.isNonNegative(num);
        expect(error).toEqual({ valid: false, error: validator.ERRORS.NonNegative });
    });
    it("should return error for bad Corporate Relationship ID", () => {
        const corpRelId = "shurkens";
        const error = validator.isCorpRelId(corpRelId);
        expect(error).toEqual({ valid: false, error: validator.ERRORS.CorpRelId });
    });
    it("should return error for bad Country", () => {
        const country = "China";
        const error = validator.isCountry(country);
        expect(error).toEqual({ valid: false, error: validator.ERRORS.Country });
    });
    it("should return error for bad Sales Rep Id", () => {
        const salesRepID = "LebronJordan";
        expect(validator.isSalesRepId(salesRepID)).toBe(false);
    });
    it("should return error for bad Segment", () => {
        const segment = "";
        const error = validator.isSegment(segment);
        expect(error).toEqual({ valid: false, error: validator.ERRORS.Segment });
    });

    describe("validator map tests", () => {
        const validatorMap = validator.validatorMap;
        it("should validate an SalesForce Account ID", () => {
            const goodData = "001sf78906";
            const badData = "-s-dfda000f";

            const error1 = validatorMap.SalesForce_Account_Id(goodData);
            const error2 = validatorMap.SalesForce_Account_Id(badData);

            expect(error1).toBe(null);
            expect(error2).toEqual(validator.ERRORS.SalesForce_Account_Id);
        });
        it("should validate an Account Name", () => {
            const goodData = "001sf78906";
            const badData = "l";

            const error1 = validatorMap.Account_Name(goodData);
            const error2 = validatorMap.Account_Name(badData);

            expect(error1).toBe(null);
            expect(error2).toEqual(validator.ERRORS.Account_Name);
        });
        it("should validate an Business Name", () => {
            const goodData = "001sf78906";
            const badData = "l";

            const error1 = validatorMap.Business_Name(goodData);
            const error2 = validatorMap.Business_Name(badData);

            expect(error1).toBe(null);
            expect(error2).toEqual(validator.ERRORS.Business_Name);
        });
        it("should validate an First Name", () => {
            const goodData = "001sf78906";
            const badData = "l";

            const error1 = validatorMap.First(goodData);
            const error2 = validatorMap.First(badData);

            expect(error1).toBe(null);
            expect(error2).toEqual(validator.ERRORS.First);
        });
        it("should validate an Last Name", () => {
            const goodData = "001sf78906";
            const badData = "l";

            const error1 = validatorMap.Last(goodData);
            const error2 = validatorMap.Last(badData);

            expect(error1).toBe(null);
            expect(error2).toEqual(validator.ERRORS.Last);
        });
        it("should validate an Primary Phone number", () => {
            const goodData = "9733333333";
            const badData = "l";

            const error1 = validatorMap.Primary_Phone(goodData);
            const error2 = validatorMap.Primary_Phone(badData);

            expect(error1).toBe(null);
            expect(error2).toEqual(validator.ERRORS.Primary_Phone);
        });
        it("should validate an Email address", () => {
            const goodData = "shurikens@yodle.com";
            const badData = "l";

            const error1 = validatorMap.Email(goodData);
            const error2 = validatorMap.Email(badData);

            expect(error1).toBe(null);
            expect(error2).toEqual(validator.ERRORS.Email);
        });
        it("should validate an Existing Domain", () => {
            const goodData = "shurkensWeWorldWide.com";
            const badData = "l";

            const error1 = validatorMap.Existing_Domain(goodData);
            const error2 = validatorMap.Existing_Domain(badData);

            expect(error1).toBe(null);
            expect(error2).toEqual(validator.ERRORS.Existing_Domain);
        });
        it("should validate Address 1", () => {
            const goodData = "P Sherman 42 Wallaby Way, Sydney";
            const badData = "l";

            const error1 = validatorMap.Address_1(goodData);
            const error2 = validatorMap.Address_1(badData);

            expect(error1).toBe(null);
            expect(error2).toEqual(validator.ERRORS.Address_1);
        });
        it("should validate Address 2", () => {
            const goodData = "P Sherman 42 Wallaby Way, Sydney";

            const error1 = validatorMap.Address_2(goodData);

            expect(error1).toBe(null);
        });
        it("should validate an City", () => {
            const goodData = "NYC";
            const badData = "NJ";
            const error1 = validatorMap.City(goodData);
            const error2 = validatorMap.City(badData);

            expect(error1).toBe(null);
            expect(error2).toBe(validator.ERRORS.City);
        });
        it("should validate an Zip", () => {
            const goodData = "07029";
            const badData = "zipCodeBruh";
            const error1 = validatorMap.Zip(goodData);
            const error2 = validatorMap.Zip(badData);

            expect(error1).toBe(null);
            expect(error2).toBe(validator.ERRORS.Zip);
        });
    });
    describe("csv validator tests", () => {
        const goodCSV = [{
            Account_Name: "Dronescapers - Somewhere",
            Address_1: "78169 Kassulke Unions",
            Address_2: "",
            Business_Name: "Dronescapers",
            City: "Princeton",
            Email: "andrew@ds.com",
            Existing_Domain: "wwwkhalil.com",
            First: "Andrew",
            Last: "Rivera",
            Primary_Phone: "9733333333",
            SalesForce_Account_Id: "001sf78906",
            State: "NJ",
            Zip: "12345",
            franchiseLocationId: "DS103",
        }];
        const badCSV = [{
            Account_Name: "e",
            Address_1: "78",
            Address_2: "",
            Business_Name: "l",
            City: "NJ",
            Email: "nah_bruh",
            Existing_Domain: "domainName",
            First: "",
            Last: "",
            Primary_Phone: "973333333",
            SalesForce_Account_Id: "--1sf78906",
            State: "New Jersey",
            Zip: "edocpiz",
            franchiseLocationId: "a",
        }];
        it("should return an empty errors array", () => {
            expect(validator.validateCSV(goodCSV).length).toBe(0);
        });
        it("should return errors array with error map and row number", () => {
            const errors = validator.validateCSV(badCSV);
            errors.forEach((error) => {
                expect(error.row !== null && error.row !== undefined && error.row !== 0).toBe(true);
                _.forEach(error.errors, (value) => {
                    expect(value.error).toEqual(validator.ERRORS[value.key]);
                });
            });
            expect(errors.length > 0).toBe(true);
        });
        it("should return duplicate email error", () => {
            const data = Object.assign({}, goodCSV);
            data[1] = Object.assign({}, data[0]);
            const errors = validator.validateCSV(data);
            expect(errors.length > 0).toBe(true);
            expect(errors[0].errors[0].value).toEqual(`Duplicate email address ${ data[0].Email }`);
        });
    });
    describe("form data options validator", () => {
        const formData = {
            centerMark: false,
            centerMarkLite: false,
            yodleWeb: false,
            salesRep: "Sales Rep",
            centerMarkMonthly: 0,
            sponsoredSetup: 0,
            centerMarkSetup: 0,
            centerMarkLiteMonthly: 0,
            centerMarkLiteSetup: 0,
            yodleWebMonthly: 0,
        };
        it("should return error when centerMark provisioned with yodleWeb", () => {
            const data = Object.assign([], formData);
            data.centerMark = data.yodleWeb = true;
            const check = validator.validateFormDataOptions(data);
            expect(check.valid).toBe(false);
            expect(check.errors[0]).toEqual(validator.ERRORS.YodleWeb);
        });
        it("should return error when centerMark provisioned with centerMarkLite", () => {
            const data = Object.assign([], formData);
            data.centerMark = data.centerMarkLite = true;
            const check = validator.validateFormDataOptions(data);
            expect(check.valid).toBe(false);
            expect(check.errors[0]).toEqual(validator.ERRORS.CenterMarkLite);
        });
        it("should return error when sales rep not chosen", () => {
            const data = Object.assign(formData);
            data.salesRep = "";
            const check = validator.validateFormDataOptions(data);
            expect(check.valid).toBe(false);
            expect(check.errors[0]).toEqual(validator.ERRORS.ChooseSalesRep);
        });
    });
});
