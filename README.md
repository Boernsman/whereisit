# whereisit

[![CI](https://github.com/Boernsman/whereisit/actions/workflows/ci.yml/badge.svg)](https://github.com/Boernsman/whereisit/actions/workflows/ci.yml)

Where is my device? And why is Zeroconf not working? Damn it!

This tool eases your pain. It helps you to find your devices.

## Usage

Start the server with:

```
./whereisit
```


Register device with:

```
curl -H "Content-Type: application/json" -X POST -d '{"name":"${DEVICE_NAME}","address":"${DEVICE_IP}"}' http://${SERVER_IP}:8180/api/register
```

List device with:

```
http://${SERVER_IP}:8180/api/devices
```

See the build in web site:

```
http://${SERVER_IP}:8180
```

## Build

```
go build .
```

## Test

```
go test .
```

## Security

Not very secure


## License

[MIT](https://tldrlegal.com/license/mit-license)
