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
* (Optional) Logging of user processes and open network connections to syslog

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

### User process logging
Logging of user processes and open network connections is disabled by default. To turn that on set `profile_audit::enable_net_process_log: true`. See REFERENCE.md for any customizations if needed.

### Qualys EUS Detection History
Qualys historically had issues on Redhat servers running an EUS release, where Qualys would not realize the server was running an EUS version and would instead report out-of-date packages based on the latest release.  In April 2024 Qualys fixed this issue in "VULSIG version VULNSIGS-2.6.33-2".

In the past this profile module had a work around to give fake output from the 'subscription-manager' command to Qualys on systems running EUS. This is no longer needed and has been removed in the latest version.

## Reference

See: [REFERENCE.md](REFERENCE.md)

## Limitations

This module depends on the following modules:
- https://forge.puppet.com/modules/puppetlabs/firewall
- https://github.com/ncsa/puppet-pam_access
- https://github.com/ncsa/puppet-sshd
- https://forge.puppet.com/modules/saz/sudo
- https://github.com/ncsa/puppet-rhsm

## Development

This Common Puppet Profile is managed by NCSA for internal usage.
