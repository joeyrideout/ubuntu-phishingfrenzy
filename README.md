`sudo docker pull redis`
`sudo docker pull mysql`
`sudo docker build -t="phishingfrenzy" github.com/Meatballs1/ubuntu-phishingfrenzy`

`sudo docker run --name pf-redis -d redis`
`sudo docker run --name pf-mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=pf_dev -e MYSQL_USER=pf_dev -e MYSQL_PASSWORD=password -d mysql:latest`
`sudo docker run --rm --link pf-mysql phishingfrenzy cd /var/www/phishing-frenzy/ && bundle exec rake db:migrate && bundle exec rake db:seed && bundle exec rake templates:load`
`sudo docker run --name pf --link pf-redis pf-mysql -d -p 80:80 phishingfrenzy`

