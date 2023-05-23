#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-only

echo "#!/bin/bash" > firewall-setup.sh
firewall-cmd --get-zones | sed -E -e 's/[[:blank:]]+/\n/g' > zones.list

while read zones
do
  echo "# Zone $zones" >> firewall-setup.sh

  echo "# Create zone." >> firewall-setup.sh
  echo "firewall-cmd --permanent --new-zone=$zones" >> firewall-setup.sh
  
  echo "# Rich Rules" >> firewall-setup.sh
  firewall-cmd --list-all --zone=$zones | grep 'rule ' | sed -e 's/^[ \t]*//' > richrule.list
  sed -i -e "s/$/'/" richrule.list
  sed -i -e "s/^/'/" richrule.list
  sed -i -e "s/^/firewall-cmd --zone=$zones --permanent --add-rich-rule=/" richrule.list
  cat richrule.list >> firewall-setup.sh
  
  echo "# Ports" >>  firewall-setup.sh
    firewall-cmd --list-all --zone=$zones | grep ports | grep 'udp\|tcp' | awk -F"ports:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > ports.list
  sed -i -e "s/^/firewall-cmd --permanent --zone=$zones --add-port=/" ports.list
  cat ports.list >> firewall-setup.sh
  
  echo "# Services" >>  firewall-setup.sh
  firewall-cmd --list-all --zone=$zones | grep services | awk -F"services:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > services.list
  sed -i -e "s/^/firewall-cmd --permanent --zone=$zones --add-service=/" services.list
  cat services.list >> firewall-setup.sh
  echo "" >>  firewall-setup.sh

done < zones.list

echo ""  >>  firewall-setup.sh

firewall-cmd --get-policies | sed -E -e 's/[[:blank:]]+/\n/g' > policies.list

while read policies
do
  echo "# Policy $policies" >> firewall-setup.sh
  echo "# Create policy." >> firewall-setup.sh
  echo "firewall-cmd --permanent --new-polixy=$policies" >> firewall-setup.sh

  echo "# Rich Rules" >> firewall-setup.sh
  firewall-cmd --list-all --policy=$policies | grep 'rule ' | sed -e 's/^[ \t]*//' > pol_richrule.list
  sed -i -e "s/$/'/" pol_richrule.list
  sed -i -e "s/^/'/" pol_richrule.list
  sed -i -e "s/^/firewall-cmd --policy=$policies --permanent --add-rich-rule=/" pol_richrule.list
  cat pol_richrule.list >> firewall-setup.sh
  
  echo "# Ports" >>  firewall-setup.sh
  firewall-cmd --list-all --policy=$policies | grep ports | grep 'udp\|tcp' | awk -F"ports:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > pol_ports.list
  sed -i -e "s/^/firewall-cmd --permanent --policy=$policies --add-port=/" pol_ports.list
  cat pol_ports.list >> firewall-setup.sh
  
  echo "# Services" >>  firewall-setup.sh
  firewall-cmd --list-all --policy=$policies | grep services | awk -F"services:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > pol_services.list
  sed -i -e "s/^/firewall-cmd --permanent --policy=$policies --add-service=/" pol_services.list
  cat pol_services.list >> firewall-setup.sh
  
  echo "# ingress-zone" >>  firewall-setup.sh
  firewall-cmd --list-all --policy=$policies | grep ingress-zones | awk -F"ingress-zones:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > pol_ingress.list
  sed -i -e "s/^/firewall-cmd --permanent --policy=$policies --add-egress-zone=/" pol_ingress.list
  cat pol_ingress.list >> firewall-setup.sh
  
  echo "# egress-zone" >>  firewall-setup.sh
  firewall-cmd --list-all --policy=$policies | grep egress-zones | awk -F"egress-zones:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > pol_egress.list
  sed -i -e "s/^/firewall-cmd --permanent --policy=$policies --add-egress-zone=/" pol_egress.list
  cat pol_egress.list >> firewall-setup.sh
  
  echo "# Target" >>  firewall-setup.sh
  TARGET=$(firewall-cmd --permanent --policy=$policies --get-target)
  echo "firewall-cmd --permanent --policy=$policies --set-target=$TARGET" >> firewall-setup.sh
  echo "" >>  firewall-setup.sh
done < policies.list

echo "firewall-cmd --reload" >> firewall-setup.sh

rm -rf ./*.list
chmod u+x firewall-setup.sh
