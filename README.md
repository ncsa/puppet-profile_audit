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

### Qualys EUS repo detection
By default this is disabled

Qualys can have issues on Redhat servers running an EUS release, where Qualys will report that your packages are out-of-date even though they are updated with the latest packages from the EUS repos.

There are two hiera settings used to fix this issue, by default they are both set to false
- `profile_audit::qualys::escalated_scans: false`
- `profile_audit::qualys_eus_reporting::enabled: false`

If your server is using an EUS release, you will need to set `profile_audit::qualys::escalated_scans: true`. This is because Qualys needs to have sudo access to run the subscription-manager command which is required for Qualys to detect if your server is running an EUS release.

If your server is configured so that the output of `subscription-manager repos --list-enabled` would list no repos, or repos that don't point to the official redhat urls (like clusters where we point servers to use a local snapshot of repos on our provisioning server instead of the repo urls from Redhat), then you also need to set `profile_audit::qualys_eus_reporting::enabled: true`. Doing so will setup an alias for root that wraps the command `subscription-manager` to a script this module installs at `/root/qualys_eus_reporting.sh`. The `qualys_eus_reporting.sh` script will 'lie' about what repos are enabled when the command `subscription-manager repos --list-enabled` is run. All other `subscription-manager` commands are executed as normal.

See this table to summarize when you need `qualys::escalated_scans` and/or `qualys_eus_reporting::enabled`:

|Server on <br />EUS Release| Using Redhat<br />repo URLs |Recommended Setting|
| --- | --- | --- |
| False | False | Default (both false) |
| False | True | Default (both false) |
| True | False | `profile_audit::qualys::escalated_scans: true`<br />`profile_audit::qualys_eus_reporting::enabled: true` |
| True | True | `profile_audit::qualys::escalated_scans: true`<br />`profile_audit::qualys_eus_reporting::enabled: false`|

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
