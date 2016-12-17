FROM ruby:2.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /app

COPY Gemfile* ./
RUN bundle install

# copying in the rest of the application
COPY . .

CMD ["rake", "crawl[true]"]
