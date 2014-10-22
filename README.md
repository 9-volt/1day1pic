# 1day1pic

A site where each day we'll post 1 picture.

## Development

Prerequisites:
* Install [ImageMagic](http://www.imagemagick.org/).
* Install [Node.js](http://nodejs.org/).
* Install Gulp and CoffeeScript globally `npm install -g gulp coffee-script`

Start developing with a local server, automatic files build and livereload:
* `git clone`
* `cd 1day1pic`
* `cp config.sample.json config.json`. You may edit config.json in order to adjust to your environment
* `npm install`
* `npm install -g gulp`
* `gulp`

In order to build the project run `gulp build`

### Database

Application requires a MySQL database. Database credentials are located in config.json file.

Sequelize CLI: `node_modules/.bin/sequelize`

Run migrations: `node_modules/.bin/sequelize db:migrate`
Undo a migration: `node_modules/.bin/sequelize db:migrate:undo`
Mock a migration: `node_modules/.bin/sequelize migration:create`

### Run

Before running in production - build sources: `gulp build`.

Run in production: `NODE_ENV=production coffee server/server.coffee`
