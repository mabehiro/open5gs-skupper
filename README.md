# Skupper Install
Install Service Interconnect Operator


# Architecture diagram


# Prerequisit

Check sctp module
````


````
# Skupper Setup

## Public Cluster

1. Create Namespace
2. Install Skupper router
3. Create token for Relay


```Console on public cluster
$ oc new-project 5g-public

$ skupper init --site-name 5gc-public

$ skupper token create ~/relay-private-a.yaml

$ skupper token create ~/relay-private-b.yaml
```


## Private A cluster

1. Create Namespace
2. Install Skupper router with ConfigMap
3. Create link to Public Cluster

````
$ oc new-project 5g-public-a

$ skupper init

$ skupper link create ~/relay-private-a.yaml

````
````Public A console
$ skupper link status

Links created from this site:

	 There are no links configured or connected

Current links from other sites that are connected:

	 Incoming link from site eda4bdf3-97cd-4a1d-807e-6bbae8740878 on namespace 5g-private-a


````


## Private B cluster

1. Create Namespace
2. Install Skupper router with ConfigMap
3. Create link to Public Cluster

```
$ oc new-project 5g-public-a

$ cat <<EOF | oc apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: skupper-site
data:
  console: "true"
  flow-collector: "true"
  console-user: "admin"
  console-password: "changeme"
EOF

$ skupper link create ~/relay-private-b.yaml
```

Skupper GUI should be avialable.

````Public A console
$ skupper link status

Links created from this site:

	 There are no links configured or connected

Current links from other sites that are connected:

	 Incoming link from site eda4bdf3-97cd-4a1d-807e-6bbae8740878 on namespace 5g-private-a
	 Incoming link from site 89673f0d-9b7e-482e-8a20-87963ad9aabd on namespace 5g-private-b

````

![Topology](./images/topology.png)



# 5GC installation

## Public cluster A

````
# oc project 5g-private-a
oc adm policy add-scc-to-user anyuid -z default
oc adm policy add-scc-to-user hostaccess -z default
oc adm policy add-scc-to-user hostmount-anyuid -z default
oc adm policy add-scc-to-user privileged -z default

````

````
helm install -f values.yaml 5g-private-a ./
````

````
skupper expose service/open5gs-amf --address open5gs-amf-skupper
skupper expose service/open5gs-ausf --address open5gs-ausf-skupper
skupper expose service/open5gs-bsf --address open5gs-bsf-skupper
skupper expose service/open5gs-pcf --address open5gs-pcf-skupper
skupper expose service/open5gs-smf --address open5gs-smf-skupper
````

## Public cluster B

````
# oc project 5g-private-b
oc adm policy add-scc-to-user anyuid -z default
oc adm policy add-scc-to-user hostaccess -z default
oc adm policy add-scc-to-user hostmount-anyuid -z default
oc adm policy add-scc-to-user privileged -z default

````

````
helm install -f values.yaml 5g-private-b ./
````

````
skupper expose service/mongodb-svc --address mongodb-svc-skupper
skupper expose service/open5gs-nrf --address open5gs-nrf-skupper
skupper expose service/open5gs-nssf --address open5gs-nssf-skupper
skupper expose service/open5gs-scp --address open5gs-scp-skupper
skupper expose service/open5gs-udm --address open5gs-udm-skupper
skupper expose service/open5gs-udr --address open5gs-udr-skupper
````

after it setttled

![Private A pods status](./images/pods-a.png)



![Private B pods status](./images/pods-b.png)


### Provisioin a subscriber

#### Private B
````
$ oc expose svc/open5gs-webui

````
there is a glitch on my webuid buid. there is workaround. refer to this
admin/1423


Then provision a subscriber (208930000000001)

![Provisioning](./images/webui-provisioning.png)


Restart 5gran pods, and monitor the logs.


## Check UE logs
we mihgt need to restart the UERANSIM pod, but once the pod finds the AMF, we should be able to see PDU session message along with TUN interface information in the log.

![gNodeB log](./images/gnb-log.png)

![UE log](./images/ue-log.png)

## Service Interconnect

Service Interconnect GUI should be able to show network topology view.

![Traffic Topology](./images/skupper-components.png)
