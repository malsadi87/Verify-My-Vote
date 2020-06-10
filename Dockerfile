FROM ruby:2.6.3

RUN mkdir -p volt

# Tools needed to build gems and assets, including PostgreSQL, noting that we need a more recent version of NodeJS and to add the Yarn repository.
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list


RUN apt-get update && apt-get install -y postgresql-client nodejs build-essential yarn
RUN yarn install

RUN apt update -y && apt install -y software-properties-common
RUN add-apt-repository ppa:ethereum/ethereum
RUN apt update -y && apt install geth

WORKDIR /volt

COPY Gemfile ./
COPY Gemfile.lock ./
RUN bundle install
COPY . . 

CMD ["rails","server","-b","0.0.0.0"]