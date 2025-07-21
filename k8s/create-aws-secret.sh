#!/bin/bash

# Create AWS secret for the application
aws secretsmanager create-secret \
  --name app/secrets \
  --description "Application secrets" \
  --secret-string '{
    "JWT_SECRET": "cyKYUEBb71A1e9wd4Up58FWlXv7pbWIwVC579BXG7/O2h5+kHLS9izhiVsVhSCpE",
    "API_KEY": "ccc0bdba8c04f8ead2306b48a88f7c5e"
  }' \
  --region us-east-2