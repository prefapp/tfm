# test_lambda.py
## File 4 local tests
from handler import lambda_handler

if __name__ == "__main__":
    event = {
        "version": "0",
        "id": "dafac799-9b88-0134-26b7-fef4d54a134f",
        "detail-type": "Backup Job State Change",
        "source": "aws.backup",
        "account": "001122334455",
        "time": "2020-07-15T21:41:17Z",
        "region": "eu-west-1",
        "resources": [
            "arn:aws:rds:eu-west-1:001122334455:snapshot:awsbackup:job-96efebc5-6db5-4d52-5747-bff86fefef1f"
        ],
        "detail": {
            "backupJobId": "a827233a-d405-4a86-a440-759fa94f34dd",
            "backupSizeInBytes": "36048",
            "backupVaultArn": "arn:aws:backup:eu-west-1:001122334455:backup-vault:common",
            "backupVaultName": "common",
            "bytesTransferred": "36048",
            "creationDate": "2020-07-15T21:40:31.207Z",
            "iamRoleArn": "arn:aws:iam::001122334455:role/MockRCBackupTestRole",
            "resourceArn": "arn:aws:service:us-west-2:001122334455:resource-type/resource-id",
            "resourceType": "type",
            "state": "COMPLETED",
            "completionDate": "2020-07-15T21:41:05.921Z",
            "startBy": "2020-07-16T05:40:31.207Z",
            "percentDone": 100,
            "retryCount": 3
        }
}

    response = lambda_handler(event, None)

    print(response)


## Entorno:
# AWS_REGION=us-west-2
# DESTINATIONS_JSON={ "001122334455": { "vault_arn": "arn:aws:backup:eu-west-3:001122334455:backup-vault:common", "regions": { "eu-west-3": {} } ,"delete_after_days": 7, "iam_role_arn": "arn:aws:iam::001122334455:role/service-role/AWSBackupDefaultServiceRole" } }

