# GreeHost Builder

## Installation

This should be installed on a freshly provisioned CentOS 7 minimal install.  SSH is assumed to be installed and running.

```bash
# Install epel-release, update software, install cpanm
yum install -y epel-release; yum update; yum -y upgrade; yum install -y perl-App-cpanminus

# Install GreeHost::Builder
# Fatal is an undeclared dependancy for Text::Xslate, failure to include it causes the build to fail (Report to xslate/p5-Text-Xslate).
cpanm Fatal GreeHost-Builder-0.001.tar.gz

# Generate a passwordless SSH keypair for Builder -> StaticServ communication
ssh-keygen -t rsa -b 4096

# Install the key on all StaticServ nodes, ensure that you ssh into each one to get it's hostkey saved
# (Left as an exercise for the reader)

# Configure the StaticServ nodes you want to deploy to:
cat > /etc/greehost.conf
{ staticserv_targets [ root@192.168.87.15 ]  }
^D
```
## Usage

This package installs thje GreeHost::Builder package and the `greehost-builder` program, greehost-builder should be run inside the top level of a project directory to deploy the project.

## Targets

### StaticServ

Add a file in the root of the project directory called `project.jsony`:

```
{ project config }
{
  target StaticServ
  domain theinternet.com
  args {
    root    html
    use_ssl 0
  }
}
```

|---------|----------------------------|-------------------------|----------|---------|
| Name    | Purpose                    | Value                   | Required | Default |
|---------|----------------------------|-------------------------|----------|---------|
| root    | The HTML webroot to serve, | Relative Directory Path | Yes      |         |
| use_ssl | Enable SSL configuration   | Boolean                 | Yes      |         |
|---------|----------------------------|-------------------------|----------|---------|


