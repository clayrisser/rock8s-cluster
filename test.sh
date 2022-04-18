while ! curl -k $RANCHER_BASE_URL/ping; do sleep 3; done
BOOTSTRAP_PASSWORD=$(kubectl get secret \
  --namespace cattle-system bootstrap-secret \
  -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}')
echo BOOTSTRAP_PASSWORD $BOOTSTRAP_PASSWORD
TOKEN=$(curl -s "$RANCHER_BASE_URL/v3-public/localProviders/local?action=login" \
  -H 'content-type: application/json' \
  --data-binary '{"username":"admin","password":"'"$BOOTSTRAP_PASSWORD"'","ttl":60000}' \
  --insecure | jq -r .token)
echo TOKEN $TOKEN
curl "$RANCHER_BASE_URL/v3/users?action=changepassword" \
  -H 'content-type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  --data-binary '{"currentPassword":"admin","newPassword":"'"$RANCHER_ADMIN_PASSWORD"'"}' \
  --insecure
curl "https://$RANCHER_BASE_URL/v3/settings/server-url" \
  -H 'content-type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -X PUT \
  --data-binary '{"name":"server-url","value":"'"$RANCHER_BASE_URL"'"}' \
  --insecure
