# Setup

Setup a place like home. Fully automated arch setup script based on [this gist](https://gist.github.com/hschne/2f079132060adf903abe3e2afdc2be96). Install all the packages, and all the CLI tools, everything.

## Requirements

This setup does not configure Arch. Use a script like [archfi](https://github.com/MatMoul/archfi) for that. Once Arch is installed you need sudo, git and a user account: 

```
pacman -S sudo git
useradd -m -g wheel -s /bin/bash <user>
passwd <user>
```

Run `visudo` and uncomment `"%wheel    ALL=(ALL) ALL"`. You will also need to set a variable `TOKEN` to your GitHub application token for this script.
Once that is done run the script. 

```
TOKEN=<your-app-token>
git clone https://github.com/glumpat/setup.git && cd setup && sudo ./setup.sh
```

Have a look at the [script](setup.sh) for more info.


## Development

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


