# profile_audit

![pdk-validate](https://github.com/ncsa/puppet-profile_audit/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_audit/workflows/yamllint/badge.svg)

NCSA Common Puppet Profiles - configure standard security audits

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with profile_audit](#setup)
    * [What profile_audit affects](#what-profile_audit-affects)
    * [Beginning with profile_audit](#beginning-with-profile_audit)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This profile installs and configures security auditing functionality used by NCSA's Security Operations.

## Setup

### What profile_audit affects

* access for qualys user
* custom root equivalence reporting script

### Beginning with profile_audit

Include profile_audit in a puppet profile file:
```
include ::profile_audit
```

## Usage

No paramters are required to be set. The default paramters should work for most NCSA deployments out of the box.

But in order to enable qualys scanning, at a minimum you will need to set the following parameters:
* `profile_audit::qualys::enabled: true`
* `profile_audit::qualys::ssh_authorized_key` for the `qualys` user.

Refer to https://wiki.ncsa.illinois.edu/display/SecOps/Qualys+Authenticated+Scanning+Host+setup to find existing public keys for projects and how to request new ones.

## Reference

See: [REFERENCE.md](REFERENCE.md)

## Limitations

This module depends on the following modules:
- https://forge.puppet.com/modules/puppetlabs/firewall
- https://github.com/ncsa/puppet-pam_access
- https://github.com/ncsa/puppet-sshd

## Development

This Common Puppet Profile is managed by NCSA for internal usage.
