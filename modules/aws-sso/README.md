```yaml
groups:
  - name: "groupA"
    description: "The Group A"
    users:
      - userA
      - userB

users:
  - name: "userA"
    email: "test@test.test"
    fullname: "userA"
  - name: "userB"
    email: "test-2@test.test"
    fullname: "userB"

permission-sets:
  - name: "permission-set-foo"
    custom-policies:
      - name: "custom-policy-foo"
    managed-policies:
      - "arn:aws:iam::aws:policy/AmazonS3FullAccess"
      - "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    inline-policies:
      - name: "inline-policy-foo"
        policy: |
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Effect": "Allow",
                "Action": [
                  "ec2:Describe*"
                ],
                "Resource": "*"
              }
            ]
          }
attachments:
  "012345678910":
    permission-set-foo:
      groups:
        - groupA
      users:
        - userA
```
