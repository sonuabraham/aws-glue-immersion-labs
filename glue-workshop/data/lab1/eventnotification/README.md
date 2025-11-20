# Lab1 Event Notification

This folder is used for testing S3 event notifications with SQS.

When you upload files to this S3 path (`s3://bucket/input/lab1/eventnotification/`), 
it will trigger an S3 event notification that sends a message to the SQS queue 
`glueworkshop-lab1-event-queue`.

## Testing

1. Upload a test file:
```bash
echo "test data" > test.txt
aws s3 cp test.txt s3://${BUCKET_NAME}/input/lab1/eventnotification/test.txt
```

2. Check the SQS queue for messages:
```bash
aws sqs receive-message --queue-url $(aws sqs get-queue-url --queue-name glueworkshop-lab1-event-queue --query 'QueueUrl' --output text)
```

3. The message will contain details about the S3 object that was created.
