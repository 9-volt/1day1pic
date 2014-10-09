# 1day1pic

A site where each day we'll post 1 picture.

## Development

Start developing with a local server, automatic files build and livereload:
* `git clone`
* `cd 1day1pic`
* `cp config.sample.json config.json`. You may edit config.json in order to adjust to your environment
* `npm install`
* `npm install -g gulp`
* `gulp`

In order to build the project run `gulp build`

Application requires a MySQL database. Database credentials are located in config.json file.

Sequelize CLI: `node_modules/.bin/sequelize`
