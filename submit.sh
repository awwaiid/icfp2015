
URL='https://davar.icfpcontest.org/teams/72/solutions'
API_TOKEN='YNLCZqJz/CBlN+jALQIxjKpiTd75GfCpwF+iXhjW3nk='

curl --user :$API_TOKEN -X POST -H "Content-Type: application/json" -d "@$1" $URL
