const path = require('path');
const jasmineReporters = require('jasmine-reporters');
jasmine.VERBOSE = true;
jasmine.getEnv().addReporter(
    new jasmineReporters.JUnitXmlReporter({
        savePath: path.resolve(__dirname, '..', '..', 'test-results')
    })
);