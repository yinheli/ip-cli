# ip cli tool

Simple ip cli tool

Usage

![](./assets/usage.gif)

```
# query
ip-cli 8.8.8.8

# query multiple ips
ip-cli 8.8.8.8 8.4.4.4 1.1.1.1

# query multiple ips with dot separate
ip-cli 8.8.8.8,8.4.4.4,1.1.1.1

# use pipe
echo -n '8.8.8.8' | xargs ip-cli
```