
LOKI_USER=$1
LOKI_PASS=$2
LOKI_HOST=$3
curl -G -s -u "$LOKI_USER:$LOKI_PASS" -H "X-Scope-OrgID: app1" "http://$LOKI_HOST/loki/api/v1/query_range"   --data-urlencode 'query={namespace="app1", pod="log-generator"}'   --data-urlencode "start=$(date -v-1H +%s)000000000"
