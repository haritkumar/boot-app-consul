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
- Login using foo:bar

![alt text](https://res.cloudinary.com/haritkumar/image/upload/v1538221036/github/consul_ui.png)

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

![alt text](https://res.cloudinary.com/haritkumar/image/upload/v1538221036/github/key_value.png)

## We can use three way to load configuration from consul
- key/value
- yaml
- file - Git

## Configure application
- Add additional jars to **pom.xml**
```sh
    <org.springframework.cloud>2.0.0.RELEASE</org.springframework.cloud>

    <dependency>
			<groupId>org.springframework.cloud</groupId>
			<artifactId>spring-cloud-starter-consul-config</artifactId>
			<version>${org.springframework.cloud}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework.cloud</groupId>
			<artifactId>spring-cloud-starter-consul-discovery</artifactId>
			<version>${org.springframework.cloud}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-actuator</artifactId>
		</dependency>
```

- create **bootstrap.yml** with following config
  
![alt text](https://res.cloudinary.com/haritkumar/image/upload/v1538218754/github/app.png)

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

![alt text](https://res.cloudinary.com/haritkumar/image/upload/v1538221036/github/api.png)

- On updating properties on consul, changes will reflect in app without restart

![alt text](https://res.cloudinary.com/haritkumar/image/upload/v1538221035/github/log.png)

