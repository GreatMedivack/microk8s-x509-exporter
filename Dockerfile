FROM ruby:2.7.6-alpine3.16

WORKDIR /app
COPY . /app

RUN apk update &&\
	apk add  --no-cache ruby-dev ruby-bundler build-base tzdata &&\
    bundle install

EXPOSE 9117

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "9117"]