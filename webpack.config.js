const path = require('path')
const webpack = require('webpack')
const NodemonPlugin = require( 'nodemon-webpack-plugin' )

// Checking if prod for extra compression under devtool and plugins
const PROD = (process.env.NODE_ENV === 'production')

const __rootDir = path.resolve(__dirname)
console.log(__rootDir);
const config = {
  devtool: PROD ? 'eval' : 'source-map',
  entry: {
    bundle: path.resolve(__rootDir, 'src', 'ui', 'index.jsx')
  },
  output: {
    path: path.join(__rootDir, 'public', 'assets'),
    filename: 'bundle.js',
    publicPath: '/static/'
  },
  resolve: {
    modules: [
      path.resolve(__rootDir, 'src', 'ui'),
      path.resolve(__rootDir, 'node_modules')
    ],
    extensions: ['.ts', '.js', '.tsx', '.jsx', '.css', '*'],
    alias: {
      pace: 'pace-progress'
    }
  },
  plugins: PROD ? [
    new webpack.DefinePlugin({ 'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV) }),
    new webpack.optimize.OccurrenceOrderPlugin(), 
    new NodemonPlugin()
  ] : [],
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        include: path.join(__rootDir, 'src', 'ui'),
        use: [
          {
            loader: 'babel-loader',
            options: {
              presets: ['es2015', 'es2017', 'react']
            }
          }
        ]
      },
      {
        test: /\.s?css$/,
        use: [
          'style-loader',
          'css-loader',
          'sass-loader'
        ]
      }
    ]
  }, 
  devServer: {
    publicPath: "/",
    contentBase: "./public/assets",
    hot: true
  }
}

module.exports = config
