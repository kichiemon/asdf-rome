<div align="center">

# asdf-rome [![Build](https://github.com/kichiemon/asdf-rome/actions/workflows/build.yml/badge.svg)](https://github.com/kichiemon/asdf-rome/actions/workflows/build.yml) [![Lint](https://github.com/kichiemon/asdf-rome/actions/workflows/lint.yml/badge.svg)](https://github.com/kichiemon/asdf-rome/actions/workflows/lint.yml)


[Rome](https://rome.tools/) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add rome
# or
asdf plugin add rome https://github.com/kichiemon/asdf-rome.git
```

rome:

```shell
# Show all installable versions
asdf list-all rome

# Install specific version
asdf install rome latest

# Set a version globally (on your ~/.tool-versions file)
asdf global rome latest

# Now rome commands are available
rome help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/kichiemon/asdf-rome/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [きちえもん](https://github.com/kichiemon/)
