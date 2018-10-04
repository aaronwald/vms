
## packer 

```sh
export PACKER_SSH_KEY=/home/foo/bar/id_rsa.pub
packer build -on-error=ask packer-virtualbox.json
vagrant box add foo builds/libvirt-centos7.box
```

## vagrant

```ruby

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "foot9"
  config.ssh.private_key_path = "/home/foo/bar/id_rsa"
end

```
