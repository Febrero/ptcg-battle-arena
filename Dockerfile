ARG RUBY_VERSION=3.2.3

# --------------------------------------
# Development

FROM ruby:$RUBY_VERSION AS development

RUN apt-get update -yqq && apt-get install -yqq build-essential \
  libpq-dev \
  vim

ENV RAILS_ENV=development
ENV RACK_ENV=development
ENV RAILS_LOG_TO_STDOUT=true  
ENV RAILS_ROOT=/usr/src/realfevr-battle-arena-apis
ENV LANG=C.UTF-8

ENV GEM_HOME=/gems
ENV BUNDLE_PATH=$GEM_HOME
ENV GEM_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH=/usr/src/realfevr-battle-arena-apis/bin:$BUNDLE_BIN:$PATH


RUN mkdir /usr/src/realfevr-battle-arena-apis
RUN mkdir -p /usr/src/realfevr-battle-arena-apis/tmp/pids
# RUN touch /usr/src/realfevr-battle-arena-apis/tmp/pids/server.pid

WORKDIR /usr/src/realfevr-battle-arena-apis

COPY Gemfile* /usr/src/realfevr-battle-arena-apis/

RUN gem install bundler \
  && bundle config set --local without 'development test' \
  && bundle install -j "$(getconf _NPROCESSORS_ONLN)" \
  && rm -rf $BUNDLE_PATH/cache/*.gem \
  && find $BUNDLE_PATH/gems/ -name "*.c" -delete \
  && find $BUNDLE_PATH/gems/ -name "*.o" -delete


COPY . /usr/src/realfevr-battle-arena-apis/

#EXPOSE 3000

# CMD [ "puma", "-C config/puma.rb"]


# --------------------------------------
# Test

FROM ruby:$RUBY_VERSION AS test

RUN apt-get update -yqq && apt-get install -yqq build-essential \
  libpq-dev \
  vim

ENV RAILS_ENV=test
ENV RACK_ENV=test
ENV RAILS_LOG_TO_STDOUT=true  
ENV RAILS_ROOT=/usr/src/realfevr-battle-arena-apis
ENV LANG=C.UTF-8

ENV GEM_HOME=/gems
ENV BUNDLE_PATH=$GEM_HOME
ENV GEM_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH=/usr/src/realfevr-battle-arena-apis/bin:$BUNDLE_BIN:$PATH

RUN mkdir /usr/src/realfevr-battle-arena-apis
RUN mkdir -p /usr/src/realfevr-battle-arena-apis/tmp/pids

WORKDIR /usr/src/realfevr-battle-arena-apis

COPY Gemfile* /usr/src/realfevr-battle-arena-apis/

RUN gem install bundler \
  && bundle config set --local without 'development test' \
  && bundle install -j "$(getconf _NPROCESSORS_ONLN)" \
  && rm -rf $BUNDLE_PATH/cache/*.gem \
  && find $BUNDLE_PATH/gems/ -name "*.c" -delete \
  && find $BUNDLE_PATH/gems/ -name "*.o" -delete


COPY . /usr/src/realfevr-battle-arena-apis


# --------------------------------------
# Staging

FROM ruby:$RUBY_VERSION AS staging


RUN apt-get update -yqq && apt-get install -yqq build-essential \
  libpq-dev \
  vim

RUN mkdir /usr/src/realfevr-battle-arena-apis
RUN mkdir -p /usr/src/realfevr-battle-arena-apis/tmp/pids

WORKDIR /usr/src/realfevr-battle-arena-apis

ENV RAILS_ENV=staging
ENV RACK_ENV=staging
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_MAX_THREADS=5
ENV WEB_CONCURRENCY=4
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_ROOT=/usr/src/realfevr-battle-arena-apis
ENV LANG=C.UTF-8

ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_ROOT=/usr/src/realfevr-battle-arena-apis
ENV LANG=C.UTF-8

ENV GEM_HOME=/gems
ENV BUNDLE_PATH=$GEM_HOME
ENV GEM_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH=/usr/src/realfevr-battle-arena-apis/bin:$BUNDLE_BIN:$PATH

ENV SECRET_KEY_BASE=blah

#COPY --from=development /gems /gems
COPY Gemfile* /usr/src/realfevr-battle-arena-apis/


RUN gem install bundler \
  && bundle config set --local without 'development test' \
  && bundle install --jobs 20 --retry 5

#COPY --from=development /usr/src/realfevr-battle-arena-apis ./
COPY . /usr/src/realfevr-battle-arena-apis/


#RUN RAILS_ENV=staging bundle exec rake -T

# RUN rm -rf node_modules tmp/* log/* app/assets vendor/assets lib/assets test \ 
#   && yarn cache clean

# RUN apk del yarn

EXPOSE 3000
CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]


# --------------------------------------
# Production

FROM ruby:$RUBY_VERSION AS production


RUN apt-get update -yqq && apt-get install -yqq build-essential \
  libpq-dev \
  vim
#RUN echo 138.68.87.95 mongodb_1 >> /etc/hosts && echo 159.89.99.74 mongodb_2 >> /etc/hosts && echo 165.227.149.136 mongodb_3 >> /etc/hosts

RUN mkdir /usr/src/realfevr-battle-arena-apis
RUN mkdir -p /usr/src/realfevr-battle-arena-apis/tmp/pids

WORKDIR /usr/src/realfevr-battle-arena-apis

ENV RAILS_ENV=production
ENV RACK_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_MAX_THREADS=5
ENV WEB_CONCURRENCY=4
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_ROOT=/usr/src/realfevr-battle-arena-apis
ENV LANG=C.UTF-8

ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_ROOT=/usr/src/realfevr-battle-arena-apis
ENV LANG=C.UTF-8

ENV GEM_HOME=/gems
ENV BUNDLE_PATH=$GEM_HOME
ENV GEM_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH=/usr/src/realfevr-battle-arena-apis/bin:$BUNDLE_BIN:$PATH

ENV SECRET_KEY_BASE=blah

#COPY --from=development /gems /gems
COPY Gemfile* /usr/src/realfevr-battle-arena-apis/


RUN gem install bundler \
  && bundle config set --local without 'development test' \
  && bundle install --jobs 20 --retry 5

#COPY --from=development /usr/src/realfevr-battle-arena-apis ./
COPY . /usr/src/realfevr-battle-arena-apis/


#RUN RAILS_ENV=production bundle exec rake -T

# RUN rm -rf node_modules tmp/* log/* app/assets vendor/assets lib/assets test \ 
#   && yarn cache clean

# RUN apk del yarn

EXPOSE 3000
CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]

