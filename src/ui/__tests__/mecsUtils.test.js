import { createAccounts,
    mecsCsvFieldMapping,
    validation,
    bulkCreation,
    getPostString,
    getObjectWithMecsFields,
    validateAccountData,
    __RewireAPI__ as mecsRewire } from "../mecsUtils";

import formData from "./fixtures/validForm";
import csvData from "./fixtures/parsedCsv";
import expectedPostData from "./fixtures/postData";

describe("mecsUtils tests", () => {
    describe("getObjectWithMecsFields", () => {
        let csvRow;

        beforeEach(() => {
            csvRow = csvData[0];
        });

        it("should transform object field names based on mapping", () => {
            const result = getObjectWithMecsFields(csvRow);
            for (const [key, val] of Object.entries(mecsCsvFieldMapping)) {
                expect(val in result).toBe(true);
                expect(result[val]).toBe(csvRow[key]);
            }
        });
    });

    describe("getPostString", () => {
        it("should build client data and corporate config from csv and form data", () => {
            const result = JSON.parse(getPostString(formData, csvData));
            const clientData = result.clientData[0];
            const expectedClientData = expectedPostData.clientData[0];
            for (const key of Object.keys(expectedClientData)) {
                expect(clientData[key]).toBe(expectedClientData[key]);
            }

            const corporateConfig = result.corporateConfig;
            const expectedCorporateConfig = expectedPostData.corporateConfig;
            for (const key of Object.keys(expectedCorporateConfig)) {
                expect(corporateConfig[key]).toBe(expectedCorporateConfig[key]);
            }
        });
    });

    describe("mecs proxy functions", () => {
        let mockReturn;
        let mecsPostMock;
        let mockInput;

        beforeEach(() => {
            mockInput = {
                some: "data",
            };
            mockReturn = "mocked";
            mecsPostMock = jest.fn(() => mockReturn);
            mecsRewire.__Rewire__("mecsPost", mecsPostMock);
        });

        describe("createAccounts", () => {
            it("should call the bulk creation MECS endpoint", () => {
                const result = createAccounts(mockInput);
                expect(mecsPostMock).toHaveBeenCalledWith(bulkCreation, mockInput);
                expect(result).toEqual(mockReturn);
            });
        });

        describe("validateAccountData", () => {
            it("should call the validation MECS endpoint", () => {
                const result = validateAccountData(mockInput);
                expect(mecsPostMock).toHaveBeenCalledWith(validation, mockInput);
                expect(result).toEqual(mockReturn);
            });
        });
    });
});