dnf module disable nodejs -y
dnf module enable nodejs:18 -y

dnf install nodejs -y

cp backend-dev.service /etc/systemd/system/backend.service

useradd expense

mkdir /app

curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/backend.zip
cd /app
unzip /tmp/backend.zip

cd /app
npm install

dnf install mysql -y

mysql -h mysql-dev.rubydevops.cloud -uroot -pExpenseApp@1 < /app/schema/backend.sql


systemctl daemon-reload
systemctl enable backend
systemctl start backend


