# Setup

[![Main](https://github.com/glumpat/setup/actions/workflows/main.yml/badge.svg)](https://github.com/glumpat/setup/actions/workflows/main.yml)

Setup a place like home. Fully automated arch setup script based on [this gist](https://gist.github.com/hschne/2f079132060adf903abe3e2afdc2be96). Install all the packages, and all the CLI tools, everything.

## Requirements

This setup does not configure Arch. Use a script like [archfi](https://github.com/MatMoul/archfi) for that. Once Arch is installed you need sudo, git and a user account: 

```
pacman -S sudo git
useradd -m -g wheel -s /bin/bash <user>
passwd <user>
```

Run `visudo` and uncomment `"%wheel    ALL=(ALL) ALL"`. You will also need to set a variable `TOKEN` to your GitHub application token for this script. You can set your token and test it by running: 

```
TOKEN=<your-app-token>
curl -H "Authorization: token $TOKEN" https://api.github.com/user
```

Once that is done run the script:

```bash
curl https://raw.githubusercontent.com/glumpat/setup/master/dist/setup.sh | sudo bash
# Alternatively, download and execute explictly
curl -LO https://raw.githubusercontent.com/glumpat/setup/master/dist/setup.sh
chmod +x setup.sh && sudo ./setup.sh
```

Have a look at the [script](setup.sh) for more info.

## Development

To modify which packages get installed edit the [setup](files/setup.md) file. 

### Testing 
In order to test if your script you can utilize Docker with a custom image. Build it using

```
docker build -t 'glumpat/setup-test' .
```

Debugging specific parts of the script is possible by attaching to the image
```
docker run --rm -ti -v $PWD:/home/ glumpat/setup-test bash
```

To execute the entire install script execute

```
./test/docker-install.sh --debug
```

### Deployment

Run [gatsh](https://github.com/hschne/gatsh/tree/master) to create a new distribution: 

```
gatsh setup.sh >> dist/setup.sh
```


