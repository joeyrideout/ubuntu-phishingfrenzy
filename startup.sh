#!/bin/sh

if [ ! -f /var/run/redis_6379.pid ]; then
        /etc/init.d/redis_6379 start
else
        rm /var/run/redis_6379.pid
        /etc/init.d/redis_6379 start
fi

if (! pgrep mysql); then
        /etc/init.d/mysql start
fi

if (! pgrep sidekiq); then
        bundle exec sidekiq -C config/sidekiq.yml &
fi
apachectl stop
apachectl -DFOREGROUND
