:local MONNAME "yandex.ru";
:local ADGUARDIP "192.168.88.100";
:local FULLIP [ip address get [find where comment="defconf"] address];
:local ROUTERIP  [:pick $FULLIP 0 [:find $FULLIP "/"]];
:local ACTIVEDNS  [/ip dhcp-server network get value-name=dns-server [find where comment="defconf"]];
:do {
       :local resolvedIP [:resolve $MONNAME server=$ADGUARDIP];
       :if ($resolvedIP != "") do={
            :log debug "DNS watchdog: AdGuard is now UP";
            :if  ($ACTIVEDNS != $ADGUARDIP) do {
                 /ip dhcp-server network set dns-server=$ADGUARDIP [find where comment="defconf"];
                 :log warning "DNS for leases was switching to $ADGUARDIP";
            }
        }
} on-error={
        :log warning "AdGuard DNS still not responding...";
        :if  ($ACTIVEDNS != $ROUTERIP) do {
              /ip dhcp-server network set dns-server=$ROUTERIP [find where comment="defconf"];
              log warning "DNS for leases was switching to $ROUTERIP";
         }
}
