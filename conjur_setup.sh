set +x

rm -rf .env
docker-compose down -v

docker-compose build

docker-compose run --no-deps --rm conjur data-key generate > data_key

export CONJUR_DATA_KEY="$(< data_key)"

echo $CONJUR_DATA_KEY

echo " "
echo "*************"
echo "setting up the environment...... "
docker-compose up -d
docker-compose exec -T conjur conjurctl wait -r 240
echo "completed"
echo "enter 'docker ps' to see the running containers and docker ps -a to see all the running and stoped containers"
echo "*************"
echo " "

echo "creating myConjurAccount for gitlab_server "
echo "***************"
echo "creating myConjurAccount and generating the api key and storing it at admin_api_key"
admin_api_key=$(docker-compose exec conjur conjurctl account create myConjurAccount | awk '/API key for admin/ {print $NF}'| tr '  \n\r' ' '|awk '{$1=$1};1')
export CONJUR_AUTHN_API_KEY=$admin_api_key
echo "${CONJUR_AUTHN_API_KEY}"
echo "created myConjurAccount"
echo "***************"

echo " "
echo " "
echo "****************"
echo " connecting to the conjur client and conjur server"
echo "****************"
echo "initiating myConjurAccount and logging in as a  admin user"
docker-compose exec client conjur init -u conjur -a myConjurAccount
echo " "
echo "****************"
echo "Log in to Conjur as admin"
echo " "
docker-compose exec client conjur authn login -u admin -p $CONJUR_AUTHN_API_KEY
echo ****************""
echo " "

#authn-jwt-gitlab configuration
echo "defining and loading the policies "
echo " "
echo "****************"
echo " authn-jwt-gitlab configuration"
echo "****************"

docker-compose exec -T client conjur policy load root policy/1.yml
docker-compose exec -T client conjur policy load root policy/2.yml
docker-compose exec -T client conjur policy load root policy/3.yml

# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/token-app-property 'root'
# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/identity-path 'gitlab/root'
# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/issuer 'http://gitlab.example.com:9080'
# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/jwks-uri 'http://gitlab.example.com:9080/-/jwks/'

docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/token-app-property 'cyberark4'
docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/identity-path 'gitlab-apps'
docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/issuer 'https://gitlab.com'
docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/jwks-uri 'https://gitlab.com/-/jwks/'
