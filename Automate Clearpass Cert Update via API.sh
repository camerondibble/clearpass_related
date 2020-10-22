#Change Dir to /
cd /

#Start HTTP Server in background
trap "kill 0" EXIT
python3 -m http.server 80 &

#Go to LetsEcrypt Dir to create PFX certificate
cd [/path/to/letsencrypt/archive/[domain] 

#openssl pkcs12 -export -out wildcard.pfx -inkey privkey1.pem -in fullchain1.pem
#above asks to create a password for pfx file. code below puts it into a single line of code with variables to automate process

#Create PFX File
full_chain="fullchain1.pem"
priv_key="privkey1.pem"
wild_pfx="wildcard.pfx"
pfx_pass="[pfx passphrase]"

openssl pkcs12 \
    -export \
    -in "$full_chain" -inkey "$priv_key" -passin pass:"$pfx_pass" \
    -passout pass:"$pfx_pass" -out "$wild_pfx"

#CURL PUT RADIUS Cert to Clearpass
curl --location --request PUT 'https://[cppm server]:443/api/server-cert/name/[server UUID]/RADIUS' \
--header 'Authorization: [Bearer Token]' \
--header 'Content-Type:  application/json' \
--data-raw '{
  "pkcs12_file_url": "http://[letsencrypt server]/path/to/letsencrypt/archive/domain/wildcard.pfx",
  "pkcs12_passphrase": "[pfx passphrase]"
}'
#CURL PUT HTTPS Cert to Clearpass
curl --location --request PUT 'https://[cppm server]:443/api/server-cert/name/[server UUID]/HTTPS' \
--header 'Authorization: [Bearer Token]' \
--header 'Content-Type:  application/json' \
--data-raw '{
  "pkcs12_file_url": "http://[letsencrypt server]/path/to/letsencrypt/archive/domain/wildcard.pfx",
  "pkcs12_passphrase": "[pfx passphrase]"
}'
exit 0
