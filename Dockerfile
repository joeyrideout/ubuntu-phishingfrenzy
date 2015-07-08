FROM ubuntu:latest

MAINTAINER b00stfr3ak

ENV DEBIAN_FRONTEND noninteractive

#BugFix
RUN ln -s -f /bin/true /usr/bin/chfn

# Add Ruby repo and install packages
RUN apt-get update && apt-get -y install software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update && apt-get -y upgrade && apt-get -y install \
 libcurl4-openssl-dev libssl-dev zlib1g-dev apache2-threaded-dev \
 libapr1-dev libaprutil1-dev php5 apache2 mysql-server git curl \
 ruby2.1 ruby2.1-dev build-essential

# Install Rails and Passenger
RUN gem install --no-rdoc --no-ri rails
RUN gem install --no-rdoc --no-ri passenger -v 5.0.6
RUN yes | passenger-install-apache2-module

# Install Redis - Just apt-get or use linked container?
RUN curl http://download.redis.io/releases/redis-stable.tar.gz \
 | tar -xz && cd redis-stable && \
 make && make install && cd utils/ && ./install_server.sh

# Clone Phishing Frenzy
RUN git clone https://github.com/pentestgeek/phishing-frenzy.git /var/www/phishing-frenzy && \
    cd /var/www/phishing-frenzy/ && \
    bundle install

# Set up Apache configuration
COPY /pf.conf /etc/apache2/sites-available/pf.conf
COPY /apache2.conf /etc/apache2/apache2.conf

RUN touch /etc/apache2/httpd.conf && \
    chown www-data:www-data /etc/apache2/httpd.conf && \
    a2ensite pf && \
    a2dissite 000-default && \
    echo "www-data ALL=(ALL) NOPASSWD: /etc/init.d/apache2 reload" >> /etc/sudoers && \
    chown -R www-data:www-data /etc/apache2/sites-available/ && \
    chown -R www-data:www-data /etc/apache2/sites-enabled/

# Initialize the Database
RUN /etc/init.d/mysql start && \
 mysqladmin -u root password "Funt1me!" && \
 mysql -uroot -pFunt1me! -e "create database pf_dev;" && \
 mysql -uroot -pFunt1me! -e "grant all privileges on pf_dev.* to 'pf_dev'@'localhost' identified by 'password';"

RUN /etc/init.d/mysql start && \
    cd /var/www/phishing-frenzy/ && \
    bundle exec rake db:migrate && \
    bundle exec rake db:seed && \
    bundle exec rake templates:load

RUN mkdir /var/www/phishing-frenzy/tmp/pids && \
    cd /var/www/phishing-frenzy/ && bundle exec sidekiq -C config/sidekiq.yml

# Set up final permissions on PF folders
RUN mkdir -p /var/www/phishing-frenzy/tmp/pids && \
    mkdir -p /var/www/phishing-frenzy/tmp/cache/assets/developments && \
    mkdir -p /var/www/phishing-frenzy/tmp/cache/assets/development && \
    mkdir -p /var/www/phishing-frenzy/tmp/cache/assets/sprockets && \
    chown -R www-data:www-data /var/www/phishing-frenzy/ && \
    chmod -R 755 /var/www/phishing-frenzy/public/uploads/

COPY /startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD /startup.sh

EXPOSE 80
