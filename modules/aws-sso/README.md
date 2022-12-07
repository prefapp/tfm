```yaml
groups:
  - name: "groupA"
    description: "The Group A"
    users:
      - userA

users:
  - name: "UserA"
    email: "test@test.test"
    fullname: "USer A"

permission-sets:
  - name: "permission-set-foo"
    custom-policies:
      - name: "custom-policy-foo"
    managed-policies:
      - "arn:aws:iam::aws:policy/AmazonS3FullAccess"
      - "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    inline-policy:
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
attachaments:
  account-0:
      permission-set-foo:
          groups:
              - groupA
          users:
              - userA
  account-1:
      permission-set-foo-2:
          groups:
              - groupC
          users:
