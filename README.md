# FirewallD export

FirewallD rules and policies export  

This script exports FirewallD rules and policies and generates a bash script to
install them.

## How to use?

To export your FirewallD rules:

```sh
./firewalld-export.sh
```

This creates a script named firewall-setup.sh which can be executed on the target host(s)
to create the same rules.

## To do after importing/installing the Rules

Since the interface names may differ (on another host they will for shure), it is up to
you to assign the interfaces to the zones.
