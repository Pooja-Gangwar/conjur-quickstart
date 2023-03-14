set +x

rm -rf .env
docker-compose down -v

docker-compose build

#generate Master key and load master key as env variable

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
#admin_api_key
#docker-compose exec conjur conjurctl account create myConjurAccount > admin_data
#admin_api_key=$(docker-compose exec -T conjur conjurctl role retrieve-key myConjurAccount:user:admin | tr -d '\r')

#creating the account
echo "creating myConjurAccount for jenkins_server "
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


#authn-jwt-jenkins configuration
echo "defining and loading the policies "
echo " "
echo "****************"
echo " authn-jwt-jenkins configuration"
echo "****************"
docker-compose exec client conjur policy load root policy/jwt/authn-jwt-jenkins.yml
docker-compose exec client conjur policy load root policy/authn-jwt-jenkins1.yml
#docker-compose exec client conjur policy load root policy/cloudbees_cli/authn-jwt-cloudbees_ci.yml

echo "set the variable values"
echo "setting the jwks-uri"

#docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins/jwks-uri 'http://jenkins_server:8080/jwtauth/conjur-jwk-set'


#docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins/public-keys ${secretVal}
docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins_enterprise/jwks-uri 'http://my_jenkins:8080/jwtauth/conjur-jwk-set'
#docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins_enterprise_cloudbees_ci/jwks-uri 'http://cloudbees_ci:8080/jwtauth/conjur-jwk-set'

echo "setting issuer"
docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins/issuer 'http://localhost:8083'
docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins_enterprise/issuer 'http://localhost:9000'
#docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins_enterprise_cloudbees_ci/issuer 'http://localhost:9001'

echo "setting the audience"
docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins/audience 'jenkins-server'
docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins_enterprise/audience 'jenkins-server'
#docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins_enterprise_cloudbees_ci/audience 'jenkins-server'

echo "setting the token-app-property"
docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins/token-app-property 'jenkins_name'
docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins_enterprise/token-app-property 'jenkins_name'
#docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins_enterprise_cloudbees_ci/token-app-property 'jenkins_name'

echo "#############"
docker-compose exec client conjur list
echo "completed"
echo "##########"

#docker-compose exec client bash


#load policy/jenkins-projects.yml

echo "loading policy jenkins-projects.yml"
docker-compose exec client conjur policy load root policy/jwt/jenkins-projects.yml
docker-compose exec client conjur policy load root policy/jenkins-projects1.yml
#docker-compose exec client conjur policy load root policy/cloudbees_cli/jenkins-projects.yml

echo "set the identity path"
docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins/identity-path 'jenkins/projects'
docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins_enterprise/identity-path 'jenkins1/projects1'
#docker-compose exec client conjur variable values add conjur/authn-jwt/jenkins_enterprise_cloudbees_ci/identity-path 'jenkins/projects2'

#load policy/jenkins-secrets.yml
echo "loading secrets jenkins-secrets.yml"
docker-compose exec client conjur policy load root policy/jwt/jenkins-secrets.yml
docker-compose exec client conjur policy load root policy/jenkins-secrets1.yml
#docker-compose exec client conjur policy load root policy/cloudbees_cli/jenkins-secrets.yml

docker-compose exec client conjur list
#echo "add secret values to the variables and store secret values into the variables listed"
#echo "command to pass the secret value to the variable: "
#echo "docker-compose exec client conjur variable values add <variable_value> <secret_value>"


echo "populating values to the conjur secret variables"
echo "========================================"
docker-compose exec client conjur variable values add mbp-secret-1  "secret1"
docker-compose exec client conjur variable values add mbp-secret-2  "secret1"
docker-compose exec client conjur variable values add mbp-secret-3  "secret1"
docker-compose exec client conjur variable values add mbp-secret-4  "secret1"
