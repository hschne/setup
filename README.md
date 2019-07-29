# Setup

Setup a place like home. Fully automated Antergos setup script. Install all the packages, and all the CLI tools.

    git clone https://github.com/glumpat/setup.git && cd setup && ./install.sh

Have a look at the [script](install.sh) for more info.

## Development

In order to test if your script you can utilize Docker. For testing single commands you may run

```
docker run --rm -ti -v $PWD:/home/ archlinux/base bash
```

To execute the install script in a sandboxed container execute

```
./test/docker-install.sh --debug
```

You may also use `--dry-run` to speed up execution by avoiding calling real commands.

