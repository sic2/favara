# Favara
A simple and easy to use crawler for web sources (fb, twitter, nodebb, etc)

**favara** is a Siculo-Arabic word meaning: water source. The Siculo-Arabic language is dead now (IX-XIV century), but we believe the word *favara* sounds great and its meaning really reflects the purpose of the project.

## What it does:
- crawls posts and events from several sources, inserting them into a database

## Supported sources:
- only FB at the moment

## How to use favara

### Requirements

- A recent version of ruby and rubygems installed.
- A Postgres database, where Favara will put the crawled data.

### Installing

- Clone this repo
- Install any dependencies via `$ bundle install`
- Configure the database - you can override the settings in `database.yml` using the following env variables
  - FAVARA_DB_ADAPTER
  - FAVARA_DB_ENCODING
  - FAVARA_DB_POOL
  - FAVARA_DB_USERNAME
  - FAVARA_DB_PASSWORD
  - FAVARA_DB_HOST
  - FAVARA_DB_DATABASE
- Configure the sources - `config.yml`

You will then have to make a choice regarding the ownership of the database tables favara uses:

#### I want favara to put its contents into some existing tables
- If you want to run Favara with isamuni, then let isamuni create the tables for you, no other configuration is required.
- You can edit the models in the models folder to reflect your tables' structure.

#### I want favara to create and manage its tables
- You can ask favara to create the required tables via `rake create_tables`.
- If you run a rails app, you can generate a new migration and then copy the contents of  `migrations/001_init.rb` inside of it.
- You also manually create the required tables by yourself referring to `migrations/001_init.rb`.
 
### Running

- Run favara issuing `rake favara` to crawl only the latest contents
- Run `rake "favara[true]` to crawl all posts from all sources
- Run `clockwork clock.rb` to leave favara running, and automatically crawl the latest posts at regular intervals (the default configurtation runs a complete crawling between 11pm and 5am).

## Make a custom crawler
Favara is designed to import the crawled contents into a database. If that doesn't suit your needs, feel free to copy the files in `crawlers/lib/*` containing the database-independent logic and use them as any other ruby library.

## Basic testing

We also provide a very thin Sinatra webservice. This is not supposed to be used in production, but it may come in handy for testing or diagnostic. To run it, simply run `ruby server.rb`, then point your browser to *localhost:4567*.

You can check the crawled events under */events* and posts under */posts*

## Use cases

- [Isamuni](https://github.com/sic2/isamuni)
