

docker-compose exec -T client conjur policy load root policy/first.yml
docker-compose exec -T client conjur policy load root policy/second.yml
docker-compose exec -T client conjur policy load root policy/third.yml

# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/token-app-property 'root'
# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/identity-path 'gitlab/root'
# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/issuer 'http://gitlab.example.com:9080'
# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/jwks-uri 'http://gitlab.example.com:9080/-/jwks/'

# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/token-app-property 'githlab-apps/cyberark4'
# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/token-app-property 'PoojaGangwarTCS'

# docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/token-app-property 'namespace_name'


docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/token-app-property 'namespace_path'

docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/token-app-property 'cyberark4'
docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/identity-path 'gitlab-apps'
      # docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/issuer 'gitlab.com'
docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/issuer 'https://gitlab.com'
docker-compose exec -T client conjur variable values add conjur/authn-jwt/gitlab/jwks-uri 'https://gitlab.com/-/jwks/'

docker exec -it conjur_client conjur variable values add Dev-Team-credential1 "UserName_temp"
docker exec -it conjur_client conjur variable values add Dev-Team-credential2 "Password_temp"
docker exec -it conjur_client conjur variable values add Dev-Team-credential3 "UserName_temp"
docker exec -it conjur_client conjur variable values add Dev-Team-credential4 "Password_temp"
