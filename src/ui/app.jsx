import React from 'react'
import BadgeForce from './components/index'
import './app.scss'

const pace = require('pace-progress')

class App extends React.Component {
  componentWillMount () {
    pace.options = {
      ajax: {
        trackMethods: ['GET', 'POST', 'PUT', 'DELETE', 'REMOVE']
      },
      restartOnRequestAfter: true
    }
    pace.start()
  }
  render () {
    return (
            <BadgeForce />
    )
  }
}

export default App
