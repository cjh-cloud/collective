
go mod init github.com/cjh-cloud/collective/go/src/go-lambda-function

go get github.com/aws/aws-lambda-go/lambda

aws iam create-role --role-name go-lambda-ex --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy --role-name go-lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o main main.go

zip function.zip main

aws lambda create-function --function-name go-lambda-function --zip-file fileb://function.zip --handle main --runtime go1.x --role arn:aws:iam::322839641907:role/go-lambda-ex

aws lambda invoke --function-name go-lambda-function --cli-binary-format raw-in-base64-out --payload '{"What is your name?": "Jim", "How old are you?": 33}' output.txt
