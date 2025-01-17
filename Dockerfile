FROM jekyll/jekyll:latest as build
WORKDIR /app
COPY --chown=jekyll:jekyll . /app
RUN chown -R jekyll:jekyll /app
RUN bundle install
RUN bundle exec jekyll doctor
RUN bundle exec jekyll build --safe -V

FROM httpd:alpine as production
COPY --from=build /app/_site /usr/local/apache2/htdocs/
EXPOSE 80/tcp
