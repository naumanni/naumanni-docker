FROM alpine:3.6 as builder
WORKDIR /var/www/

RUN apk --no-cache add curl-dev gcc linux-headers musl-dev openssl-dev python3 python3-dev yarn

# copy server code
COPY naumanni-server ./naumanni-server
COPY config.py.docker ./naumanni-server/config.py
# copy server plugins
COPY plugins ./naumanni-server/plugins
# copy frontend
COPY naumanni ./naumanni-front
COPY config.es6.docker ./naumanni-front/config.es6

# install server
RUN cd /var/www/naumanni-server \
  && python3 -m venv .env \
  && . .env/bin/activate \
  && python setup.py develop \
  && sh -c 'for d in `ls -d ./plugins/*`; do (cd ${d} && python setup.py develop) ; done' \
  && cd /var/www/naumanni-front \
  && naumanni gen js > plugin_entries.es6 \
  && naumanni gen css > plugin_entries.css \
  && yarn install \
  && naumanni gen yarn | sh \
  && NODE_ENV=production yarn build \
  && (cd static && find . | grep -E '.(js|css)$' | xargs -I{} sh -c 'cat {} | gzip -9 -c > {}.gz')


# build running server
FROM alpine:3.6
WORKDIR /var/www/

RUN apk --no-cache add libcurl libssl1.0 nginx python3 redis

# copy nginx.conf
RUN rm /etc/nginx/conf.d/default.conf && mkdir -p /run/nginx/
ADD ./naumanni.conf /etc/nginx/conf.d/

COPY run.sh /var/www/
COPY --from=builder /var/www/naumanni-server /var/www/naumanni-server
COPY --from=builder /var/www/naumanni-front/www /var/www/naumanni
COPY --from=builder /var/www/naumanni-front/static /var/www/naumanni/static

EXPOSE 80
CMD ["sh", "/var/www/run.sh"]
