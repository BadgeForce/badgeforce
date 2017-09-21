import React from "react";
import * as issuerUtils from "../issuerUtils";
import _ from 'lodash';

class Intro extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            name: "",
            url: "",
            address: "", 
            badges: {}
        };
    }
    componentDidMount() {
        var self = this;
        issuerUtils.getIssuerInfo((name, url, address, badges) => {
            self.setState({name: name, url:url, address:address, badges: badges});
        }, err => {
            console.log(err);
        });
    }
    render() {
        return (
            <div className="span10">
                <br/>
                <h1>
                    {this.state.name}
                </h1>
                <h1>
                    {this.state.url}
                </h1>
                <h1>
                    {this.state.address}
                </h1>
                <div>
                    {_.values(this.state.badges).map((badge, i) => {
                        return <span key={i}>
                            {badge.map((data, j) => {
                                return _.isObject(data) ? null : <p key={j}>{data}</p>
                            })}
                        </span>
                    })}
                </div>
            </div>
        );
    }
}
export default Intro;
