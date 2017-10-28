FROM ubuntu:16.04

MAINTAINER Jose Lloret <jollopre@gmail.com>

ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.3
ENV RUBY_DOWNLOAD_SHA256 241408c8c555b258846368830a06146e4849a1d58dcaf6b14a3b6a73058115b7
ENV RUBYGEMS_VERSION 2.6.8
ENV BUNDLER_VERSION 1.13

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		bzip2 \
		ca-certificates \
		libffi-dev \
		libgdbm3 \
		libssl-dev \
		libyaml-dev \
		procps \
		zlib1g-dev \
		tzdata \
		cron \
	&& rm -rf /var/lib/apt/lists/*

ARG BUILD_DEPS='\
		bison \
		gcc \
		libbz2-dev \
		libgdbm-dev \
		libglib2.0-dev \
		libncurses-dev \
		libreadline-dev \
		libxml2-dev \
		libxslt-dev \
		ruby \
		wget'

RUN apt-get update \
	&& apt-get install -y --no-install-recommends ${BUILD_DEPS} \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget -O ruby.tar.gz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.gz" \
	&& echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/src/ruby \
	&& tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 \
	&& rm ruby.tar.gz \
	&& cd /usr/src/ruby \
	&& ./configure --disable-install-doc --enable-shared \
	&& make -j"$(nproc)" \
	&& make install \
	&& cd / \
	&& rm -r /usr/src/ruby \
	&& gem update --system "$RUBYGEMS_VERSION"

RUN gem install bundler --version "$BUNDLER_VERSION"

# Environment variables for bundle
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_BIN="$GEM_HOME/bin" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
	&& chmod 744 "$GEM_HOME" "$BUNDLE_BIN"

# Install Rails and its dependencies
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	nodejs \
	libsqlite3-dev \
	sqlite3 \
	&& rm -rf /var/lib/apt/lists/*

ENV WORKDIR /usr/src/app
WORKDIR $WORKDIR
COPY ./web/Gemfile* ./
RUN bundle install

# Add cron
RUN echo "#/bin/bash" > /root/env.sh \
	&& echo $GEM_HOME | sed 's/^\(.*\)$/export GEM_HOME=\1/g' >> /root/env.sh \
	&& echo $BUNDLE_PATH | sed 's/^\(.*\)$/export BUNDLE_PATH=\1/g' >> /root/env.sh \
	&& echo $BUNDLE_BIN | sed 's/^\(.*\)$/export BUNDLE_BIN=\1/g' >> /root/env.sh \
	&& echo $BUNDLE_APP_CONFIG | sed 's/^\(.*\)$/export BUNDLE_APP_CONFIG=\1/g' >> /root/env.sh \
	&& echo $PATH | sed 's/^\(.*\)$/export PATH=\1/g' >> /root/env.sh \
	&& echo $WORKDIR | sed 's/^\(.*\)$/export WORKDIR=\1/g' >> /root/env.sh
COPY ./exchange-rate-cron.sh /root/exchange-rate-cron.sh
COPY ./exchange-rate-cron /etc/cron.d/exchange-rate-cron
RUN crontab /etc/cron.d/exchange-rate-cron

# Remove dependencies to build the image
RUN apt-get purge -y --auto-remove ${BUILD_DEPS}

VOLUME $WORKDIR

EXPOSE 3000

CMD cron && rails s -b 0.0.0.0 -p 3000