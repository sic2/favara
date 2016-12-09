# Favara
A simple and easy to use crawler for web sources (fb, twitter, nodebb, etc)

**favara** is a Siculo-Arabic word meaning: water source. The Siculo-Arabic language is dead now (IX-XIV century), but we believe the word *favara* sounds great and its meaning really reflects the purpose of the project.

## What is does:
- crawls posts and events from several sources, inserting them into a database

## Supported sources:
- only FB at the moment

## How to use favara

### Requirements

- Ruby

### Basic Usage

- Clone this repo
- Install any dependencies via `$ bundle install`
- Configure the database - `database.yml`
- Configure the sources - `config.yml`
- Create the needed tables in your database via `rake create_tables`.
     Note, you can also create the tables using any other mean, or ship your table layout,
     just ignore this step and customize the models in the models folder
- Run favara with `rake favara`

By default, favara will not crawl all the content at the specified sources.
If you want to crawl all data, you will have explicitly state that by running: `rake favara[true]`

### Advanced Usage

Run a cron job on favara via clockwork

```bash
$ clockwork clock.rb
```

**NOTE**: Our clockwork configuration runs full crawling operations only between 11pm and 5am.

## Integrating favara with a rails managed database
Generate a new empty migration and copy the contents of `migrations/001_init.rb` inside it.
Then run `rake db:migrate` in your rails app.

**NOTE**: this will assume no tables with the same name already exist

## Make a custom crawler
Well, feel free to copy the files in `crawlers/lib/*` and use them as standard ruby libraries

## Basic testing

We also provide a very thin Sinatra webservice. This is not supposed to be used in production.
You could, however, use the Sinatra server to test that your *favara* instance is working correctly.

Run `ruby server.rb`

Then open your browser to *localhost:4567*
You can check events under */events* and posts under */posts*

## Use cases

- [Isamuni](https://github.com/sic2/isamuni)
