FROM jekyll/jekyll:4

WORKDIR /app

COPY --chown=1000:1000 . .

RUN bundle update