const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => {
  const isDev = options.mode == 'development';

  return {
    optimization: {
      minimizer: [
        new OptimizeCSSAssetsPlugin({})
      ]
    },
    entry: {
      'app': './css/app.scss'
    },
    resolve: {
      extensions: ['.js', '.elm'],
      modules: ['node_modules']
    },
    output: {
      filename: '[name].js',
      path: path.resolve(__dirname, './dist/js')
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader'
          }
        },
        {
          test: /\.css$/,
          use: [MiniCssExtractPlugin.loader, 'css-loader']
        },
        {
          test: /\.scss$/,
          use: [
            MiniCssExtractPlugin.loader,
            'css-loader',
            'sass-loader'
          ]
        }
      ]
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: "../css/[name].css"
      })
    ]
  }
};
