import React from "react";
import renderer from "react-test-renderer";
import { shallow } from "enzyme";
import CSVErrors from "../csv-errors";
import { csvErrors } from "./fixtures/csv";
import Intro from "../intro";
import CSVArea from "../csv";

describe("Presentational component tests", () => {
    describe("CSVErrors component tests", () => {
        it("should render proper CSVErrors component with no errors", () => {
            const tree = renderer.create(<CSVErrors errors={[]} />).toJSON();
            expect(tree).toMatchSnapshot();
        });
        it("should render proper CSVErrors component with more than one error", () => {
            const tree = renderer.create(<CSVErrors errors={csvErrors} />).toJSON();
            expect(tree).toMatchSnapshot();
        });

        describe("CSVErrors visibility tests", () => {
            let csvErrorsComp;
            beforeEach(() => {
                csvErrorsComp = shallow(<CSVErrors errors={csvErrors} />);
            });

            it("should collapse and uncollapse CSVErrors area", () => {
                csvErrorsComp.find("#csv-errors-visibility-button").simulate("click");
                expect(csvErrorsComp.state("open")).toEqual(false);
                expect(csvErrorsComp).toMatchSnapshot();

                csvErrorsComp.find("#csv-errors-visibility-button").simulate("click");
                expect(csvErrorsComp.state("open")).toEqual(true);
            });
        });
    });

    describe("Intro component tests", () => {
        it("should render proper Intro component", () => {
            const tree = renderer.create(
                <Intro />
            ).toJSON();
            expect(tree).toMatchSnapshot();
        });
    });

    describe("CSVArea component tests", () => {
        it("should render proper CSVArea component", () => {
            const tree = renderer.create(
                <CSVArea />
            ).toJSON();
            expect(tree).toMatchSnapshot();
        });
    });
});
