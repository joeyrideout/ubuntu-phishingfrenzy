`sudo docker pull redis`
`sudo docker pull mysql`
`sudo docker build -t="phishingfrenzy" github.com/Meatballs1/ubuntu-phishingfrenzy`

`sudo docker run --name pf-redis -d redis`
`sudo docker run --name pf-mysql -e MYSQL_ROOT_PASSWORD=password MSQL_DATABASE=pf_dev MYSQL_USER=pf_dev MYSQL_PASSWORD=password -d mysql:5.7.7`
`sudo docker run --name pf --link pf-redis pf-mysql -d -p 80:80 phishingfrenzy`

