#!/bin/bash


echo "#!/bin/bash" > bash_firewalld_rules_export.sh
firewall-cmd --get-zones | sed -E -e 's/[[:blank:]]+/\n/g' > zones.list

while read zones
do
  echo "# Zone $zones" >> bash_firewalld_rules_export.sh
  echo "# Rich Rules" >> bash_firewalld_rules_export.sh
  firewall-cmd --list-all --zone=$zones | grep 'rule ' | sed -e 's/^[ \t]*//' > richrule.list
  sed -i -e 's/$/"/' richrule.list
  sed -i -e 's/^/"/' richrule.list
  sed -i -e "s/^/firewall-cmd --zone=$zones --permanent --add-rich-rule=/" richrule.list
  cat richrule.list >> bash_firewalld_rules_export.sh
  echo "# Ports" >>  bash_firewalld_rules_export.sh
  firewall-cmd --list-all --zone=$zones | grep ports | grep 'udp\|tcp' | awk -F"ports:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > ports.list
  sed -i -e "s/^/firewall-cmd --permanent --zone=$zones --add-port=/" ports.list
  cat ports.list >> bash_firewalld_rules_export.sh
  echo "# Services" >>  bash_firewalld_rules_export.sh
  firewall-cmd --list-all --zone=$zones | grep services | awk -F"services:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > services.list
  sed -i -e "s/^/firewall-cmd --permanent --zone=$zones --add-service=/" services.list
  cat services.list >> bash_firewalld_rules_export.sh
  echo "" >>  bash_firewalld_rules_export.sh

done < zones.list

echo ""  >>  bash_firewalld_rules_export.sh

firewall-cmd --get-policies | sed -E -e 's/[[:blank:]]+/\n/g' > policies.list

while read policies
do
  echo "# Policy $policies" >> bash_firewalld_rules_export.sh
  echo "# Rich Rules" >> bash_firewalld_rules_export.sh
  firewall-cmd --list-all --policy=$policies | grep 'rule ' | sed -e 's/^[ \t]*//' > pol_richrule.list
  sed -i -e 's/$/"/' pol_richrule.list
  sed -i -e 's/^/"/' pol_richrule.list
  sed -i -e "s/^/firewall-cmd --policy=$policies --permanent --add-rich-rule=/" pol_richrule.list
  cat pol_richrule.list >> bash_firewalld_rules_export.sh
  echo "# Ports" >>  bash_firewalld_rules_export.sh
  firewall-cmd --list-all --policy=$policies | grep ports | grep 'udp\|tcp' | awk -F"ports:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > pol_ports.list
  sed -i -e "s/^/firewall-cmd --permanent --policy=$policies --add-port=/" pol_ports.list
  cat pol_ports.list >> bash_firewalld_rules_export.sh
  echo "" >>  bash_firewalld_rules_export.sh
  echo "# Services" >>  bash_firewalld_rules_export.sh
  firewall-cmd --list-all --policy=$policies | grep services | awk -F"services:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > pol_services.list
  sed -i -e "s/^/firewall-cmd --permanent --policy=$policies --add-service=/" pol_services.list
  cat pol_services.list >> bash_firewalld_rules_export.sh
  echo "" >>  bash_firewalld_rules_export.sh
  echo "# Target" >>  bash_firewalld_rules_export.sh
  TARGET=$(firewall-cmd --permanent --policy=$policies --get-target)
  echo "firewall-cmd --permanent --policy=$policies --set-target=$TARGET" >> bash_firewalld_rules_export.sh
  echo "" >>  bash_firewalld_rules_export.sh
done < policies.list

echo "firewall-cmd --reload" >> bash_firewalld_rules_export.sh

rm -rf ./*.list
