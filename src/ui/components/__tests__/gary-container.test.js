jest.mock("../../../validators", () => {
    return {
        validateFormDataOptions: jest.fn(),
    };
});

jest.mock("../../../mecsUtils", () => {
    return {
        validateAccountData: jest.fn(),
        createAccounts: jest.fn(),
    };
});

import React from "react";
import { shallow } from "enzyme";
import GaryContainer from "../gary-container";
import { validateFormDataOptions } from "../../../validators";
import { validateAccountData, createAccounts } from "../../../mecsUtils";

describe("GaryContainer component tests", () => {
    let wrapper;
    let showFormErrorNotification;
    let showNotification;
    let setFormValidity;
    let setValidateResult;
    let setCreateResult;
    let deferExpects;

    beforeEach(() => {
        setFormValidity = (valid) => {
            validateFormDataOptions.mockImplementation(() => {
                return { valid: valid };
            });
        };
        setValidateResult = (data) => {
            validateAccountData.mockImplementation(() => {
                return Promise.resolve({
                    data: data,
                });
            });
        };
        setCreateResult = (data) => {
            createAccounts.mockImplementation(() => {
                return Promise.resolve({
                    data: data,
                });
            });
        };

        // because we have to wait for side effects to finish
        deferExpects = (fn, time) => {
            const wait = setTimeout(() => {
                clearTimeout(wait);
                fn();
            }, time);
        };

        showFormErrorNotification = jest.fn();
        showNotification = jest.fn();
        GaryContainer.prototype.showFormErrorNotification = showFormErrorNotification;
        GaryContainer.prototype.showNotification = showNotification;
        wrapper = shallow(<GaryContainer/>);
    });

    afterEach(() => {
        validateFormDataOptions.mockClear();
        validateAccountData.mockClear();
        createAccounts.mockClear();
        showFormErrorNotification.mockClear();
        showNotification.mockClear();
    });

    it("should call showFormErrorNotification when submit button is clicked and frontend form validation fails", (done) => {
        setFormValidity(false);
        wrapper.find("#submit-btn").simulate("click");
        deferExpects(() => {
            expect(showFormErrorNotification).toHaveBeenCalled();
            done();
        }, 20);
    });

    it("should call showFormErrorNotification when submit button is clicked and backend form data validation fails ", (done) => {
        setFormValidity(true);
        setValidateResult({
            errors: [{
                message: "bad stuff",
                fieldValue: "importantField",
            }],
        });
        wrapper.find("#submit-btn").simulate("click");
        deferExpects(() => {
            expect(showFormErrorNotification).toHaveBeenCalled();
            done();
        }, 25);
    });

    it("should call validateAccountData and createAccounts when submit button is clicked and form data is valid", (done) => {
        setFormValidity(true);
        setValidateResult({
            errors: [],
        });
        setCreateResult({
            asyncStatusUrl: "someurl.com",
        });
        wrapper.find("#submit-btn").simulate("click");

        // wait for side effects to complete
        deferExpects(() => {
            expect(showFormErrorNotification).not.toHaveBeenCalled();
            expect(validateAccountData).toHaveBeenCalled();
            expect(createAccounts).toHaveBeenCalled();
            expect(showNotification).toHaveBeenCalledWith("Validation", "Account data being validated in Yodle system", "info");
            expect(showNotification).toHaveBeenLastCalledWith("Account Creation", "Account creation success", "info");
            done();
        }, 25);
    });

    it("should call showNotification with an error when submit button is clicked and account creation returns an error", (done) => {
        setFormValidity(true);
        setValidateResult({
            errors: [],
        });
        createAccounts.mockImplementation(() => {
            return Promise.reject("oh no!");
        });
        wrapper.find("#submit-btn").simulate("click");

        // wait for side effects to complete
        deferExpects(() => {
            expect(showFormErrorNotification).not.toHaveBeenCalled();
            expect(validateAccountData).toHaveBeenCalled();
            expect(createAccounts).toHaveBeenCalled();
            expect(showNotification).toHaveBeenCalledWith("Validation", "Account data being validated in Yodle system", "info");
            expect(showNotification).toHaveBeenLastCalledWith("Account Creation", "Account creation failed", "error", 15);
            done();
        }, 25);
    });
});