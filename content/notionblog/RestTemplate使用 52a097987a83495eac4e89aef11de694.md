# RestTemplate使用

date: March 21, 2023
inList: No
inMenu: No
publish: Yes
tags: Spring, 归档
template: post

## 初始化

RestTemplate未来是要被弃用的，现在推荐使用webclient。

如果轻度使用，直接new一个RestTemplate就可以。

最小引用包是spring-web，如果引入spring-boot-starter-web这种很重的包会顺带启动tomcat。

在service中自动注入RestTemple restTemple.

自动注入需要先实力化，可以在启动类中（spring的各种初始化没认真看，得找个时间细学一下）

```java
@Bean
    public RestTemplate restTemplate(RestTemplateBuilder builder) {
        return builder.build();
    }
```

## 使用

### post

```java
MultiValueMap<String,String> params = new LinkedMultiValueMap<>();
params.add("key","value");
UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl("url");
URI uri = builder.build().encode().toUri();
ResponseEntity<MyClass> response = restTemplate.postForEntity(uri,params,MyClass.class);
```

### get

```java
restTemplate.getForEntity(uri,MyClass.class);
```

### get方法拼接参数

```java
// request url
String url = "https://google.com/search?q={q}";

// create an instance of RestTemplate
RestTemplate restTemplate = new RestTemplate();

// make an HTTP GET request
String html = restTemplate.getForObject(url, String.class, "java");
response.getBody();
```

### 中文乱码问题：

```java
restTemplate.getMessageConverters().set(1,new StringHttpMessageConverter(StandardCharsets.UTF_8));
```

## 测试

自动注入RestTemplate restTemplate，自己初始化一个也可以。

创建一个MockRestServiceServer实例

```java
public void setUp() {
        RestGatewaySupport gateway = new RestGatewaySupport();
        gateway.setRestTemplate(restTemplate);
        mockServer = MockRestServiceServer.createServer(gateway);
    }
```

在Test方法中

```java
mockServer.expect(ExpectedCount.once(), MockRestRequestMatchers.requestTo(url))
.andExpect(MockRestRequestMatchers.method(HttpMethod.POST))
.andExpect(MockRestRequestMatchers.content().formData(params))               
.andRespond(MockRestResponseCreators.withStatus(HttpStatus.OK)
                        .contentType(MediaType.APPLICATION_JSON_UTF8)
                        .body(response));
```