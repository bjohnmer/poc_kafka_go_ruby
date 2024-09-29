FROM ruby:3.3.5

WORKDIR /app

COPY Gemfile ./
RUN bundle install

COPY subscriber.rb ./

CMD ["ruby", "subscriber.rb"]
