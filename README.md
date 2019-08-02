# Setup

Setup a place like home. Fully automated Antergos setup script. Install all the packages, and all the CLI tools.

    git clone https://github.com/glumpat/setup.git && cd setup && ./install.sh

Have a look at the [script](install.sh) for more info.



## Development

In order to test if your script you can utilize Docker with a custom imagge. Build it using

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


