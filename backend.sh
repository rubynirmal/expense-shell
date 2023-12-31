#!/bin/bash

source common.sh

if [ -z "$1" ]; then
  echo "Password input missing"
  exit
fi

MYSQL_ROOT_PASSWORD=$1

status_check() {
  if [ $? -eq 0 ]; then
    echo -e "\e[32mSUCCESS\e[0m"
  else
    echo -e "\e[31mFAILURE\e[0m"
  fi
}

echo -e "${color}Disable NodeJS default version\e[0m"
dnf module disable nodejs -y &>>$log_file
status_check

echo -e "${color}Enable NodeJS 18 Version\e[0m"
dnf module enable nodejs:18 -y &>>$log_file
status_check

echo -e "${color}Install NodeJS\e[0m"
dnf install nodejs -y &>>$log_file
status_check

echo -e "${color}Copy Backend Service File\e[0m"
cp backend.service /etc/systemd/system/backend.service &>>$log_file
status_check

id expense &>>$log_file
if [ $? -ne 0 ]; then
  echo -e "${color}Add Application user\e[0m"
  useradd expense &>>$log_file
  status_check
fi

if [ ! -d /app ]; then
  echo -e "${color}Create Application Directory\e[0m"
  mkdir /app &>>$log_file
  status_check
fi

echo -e "${color}Delete old Application content\e[0m"
rm -rf /app/* &>>$log_file
status_check

echo -e "${color}Download Application content\e[0m"
curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/backend.zip &>>$log_file
status_check

echo -e "${color}Extract Application content\e[0m"
cd /app &>>$log_file
unzip /tmp/backend.zip &>>$log_file
status_check

echo -e "${color}Download NodeJS Dependencies\e[0m"
npm install &>>$log_file
status_check

echo -e "${color}Install MySQL Client to Load Schema\e[0m"
dnf install mysql -y &>>$log_file
status_check

echo -e "${color}Load Schema\e[0m"
mysql -h mysql-dev.rubydevops.cloud -uroot -p$MYSQL_ROOT_PASSWORD < /app/schema/backend.sql &>>$log_file
status_check

echo -e "${color}Starting Backend Service\e[0m"
systemctl daemon-reload &>>$log_file
systemctl enable backend &>>$log_file
systemctl start backend &>>$log_file
status_check
