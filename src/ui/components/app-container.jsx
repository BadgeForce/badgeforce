import React from "react";
import Intro from "./intro";
const pace = require("pace-progress");

class AppContainer extends React.Component {
    constructor(props) {
        super(props);
        this.state = {};
    }
    componentDidMount() {
    }
    render() {
        return (
            <div>
                <Intro />
            </div>
        );
    }
}

export default AppContainer;
