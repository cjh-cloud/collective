go mod tidy
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/main cmd/main.go
zip -jrm build/main.zip build/main

Had to create Lambda, DynamoDB table & API Gateway

curl -X GET https://jbh6nuf7yf.execute-api.ap-southeast-2.amazonaws.com/staging

curl --header "Content-Type: application/json" --request POST --data '{"email": "test@mailchimp.com", "firstName": "Bob", "lastName": "Burger"}' https://jbh6nuf7yf.execute-api.ap-southeast-2.amazonaws.com/staging