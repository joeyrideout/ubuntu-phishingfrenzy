FROM ubuntu:latest

MAINTAINER b00stfr3ak

ENV DEBIAN_FRONTEND noninteractive

RUN ln -s -f /bin/true /usr/bin/chfn

RUN apt-get update && apt-get -y install software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update && apt-get -y upgrade && apt-get -y install \
 libcurl4-openssl-dev libssl-dev zlib1g-dev apache2-threaded-dev \
 libapr1-dev libaprutil1-dev php5 apache2 git curl \
 ruby2.1 ruby2.1-dev build-essential

RUN gem install --no-rdoc --no-ri rails
RUN gem install --no-rdoc --no-ri passenger -v 5.0.6

COPY /pf.conf /etc/apache2/sites-available/pf.conf

RUN git clone https://github.com/pentestgeek/phishing-frenzy.git /var/www/phishing-frenzy
RUN touch /etc/apache2/httpd.conf
RUN chown www-data:www-data /etc/apache2/httpd.conf

RUN yes | passenger-install-apache2-module

COPY /apache2.conf /etc/apache2/apache2.conf
RUN a2ensite pf
RUN a2dissite 000-default

RUN echo "www-data ALL=(ALL) NOPASSWD: /etc/init.d/apache2 reload" >> /etc/sudoers

RUN cd /var/www/phishing-frenzy/ && bundle install
RUN cd /var/www/phishing-frenzy/ && bundle exec rake db:migrate && bundle exec rake db:seed

RUN sudo chown -R www-data:www-data /var/www/phishing-frenzy/

RUN cd /var/www/phishing-frenzy/ && bundle exec rake templates:load

RUN chown -R www-data:www-data /etc/apache2/sites-available/

RUN chown -R www-data:www-data /etc/apache2/sites-enabled/

RUN chown -R www-data:www-data /var/www/phishing-frenzy/public/uploads/

RUN chmod -R 755 /var/www/phishing-frenzy/public/uploads/

COPY /startup.sh /startup.sh

RUN chmod +x /startup.sh

CMD /startup.sh

EXPOSE 80
