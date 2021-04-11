FROM ruby:3.0.0

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update -qq && \
    apt-get install -y build-essential nodejs vim

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install yarn

ENV APP_ROOT /my_app
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

RUN gem update --system && \
    gem install --no-document bundler

ADD ./Gemfile $APP_ROOT/Gemfile
ADD ./Gemfile.lock $APP_ROOT/Gemfile.lock
ADD ./package.json $APP_ROOT/

RUN bundle install --jobs 4 --retry 3
RUN bundle exec rails webpacker:install
RUN bundle exec rails assets:precompile
ADD . $APP_ROOT
