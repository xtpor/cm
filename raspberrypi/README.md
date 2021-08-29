
# scripts for provision a new raspberry pi

```
probe.sh      check whether a newly installed raspberry pi is ready
provision.sh  provision a new raspberry pi (install wireguard and docker)
```


## Cheatsheet

```
ansible all -i hosts.txt -u admin -m ping
```


```
ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"
```



# Check whether registry is set

```
/etc/rancher/k3s/registries.yaml
```

```
crictl info
```

check the `registry` section of the output
