# Consul distributed config and service discovery
- Update application configuration without restarting app/pod/instance
- Service discovery
  
![alt text](https://res.cloudinary.com/haritkumar/image/upload/v1538216922/github/consul.png)


## Start consul server
```sh
docker build -t consul .
docker run -p 8080:8080 consul
```
- Access consul web ui http://localhost:8080/ui/
- create a key/value 
```sh
config/application/data

spring:
  datasource:
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/asicdv?useSSL=false
    username: root
    password: rootchanged
```
## We can use three way to load configuration from consul
- key/value
- yaml
- file - Git

## Configure application
- create bootstrap.yml with following config
```sh
spring:
  datasource:
    driverClassName: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/asicdv?useSSL=false
    username: root
    password: root    
  jpa:
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL5InnoDBDialect
    hibernate:
      jpa.generate-ddl: true
      ddl-auto: update
server:
  port: 8081 
```
- Start application http://localhost:8081/



https://github.com/spring-cloud/spring-cloud-consul/blob/master/docs/src/main/asciidoc/spring-cloud-consul.adoc

https://localise.biz/free/converter
docker build -t consul .
docker run -p 8500:8500 -p 8082:8082 consul
docker run  -p 8080:8080 consul
http://localhost:8080/status
https://github.com/hashicorp/docker-consul/blob/36498f6d97bdf367a2cfa8ac94faad2d83c52f56/0.X/Dockerfile
https://github.com/jasonchw/docker-alpine-nginx-basic-auth

http://localhost:8080/v1/catalog/datacenters
https://github.com/jasonchw/docker-alpine-nginx-basic-auth

https://www.tuturself.com/posts/view?menuId=3&postId=1273