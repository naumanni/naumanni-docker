#!/bin.sh

redis-server &
(cd naumanni-server && . .env/bin/activate && naumanni webserver) &
exec nginx -g 'daemon off;'
