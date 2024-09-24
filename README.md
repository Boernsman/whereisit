# whereisit

Where is my device? And why is Zeroconf not working? Damn it!
This tools helps you to find your devices.

## Usage

Register device with:
```
curl -H "Content-Type: application/json" -X POST -d '{"name":"mydevice","address":"192.168.1.100"}' http://${SERVER_IP}:8180/api/register
```

List device with:
```
http://${SERVER_IP}:8180/api/devices
```

See the build in web site:
```
http://${SERVER_IP}:8180
```

## Cross compile
```
go build .`
```

## Security

Not very secure


## License
[MIT](https://tldrlegal.com/license/mit-license)
