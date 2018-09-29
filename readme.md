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