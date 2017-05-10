#!/bin/sh -ex
#
# http://guides.rubyonrails.org/getting_started.html
# gems => sorcery

websitename='temp'
idtype='primary_key' # smallserial
pguser='pguser123'
pgpass='123soleil'

ruby -v
rails --version
#exit

# générer le framework local
rails new "$websitename" -d postgresql --skip-git
cp -v .gitignore "$websitename"
rm -v "$websitename"/README.md
cd "$websitename"

# configuration de la BDD
sed -i 's/^\(.*\)#\(username:\).*$/\1\2 '"$pguser"/ config/database.yml
sed -i 's/^\(.*\)#\(password:\).*$/\1\2 '"$pgpass"/ config/database.yml

# création de la BDD
sudo -u postgres psql <<EOF
create user "$pguser" with password '$pgpass';
create database "${websitename}_development" owner "$pguser";
\\q
EOF

# ajouter les contrôleurs
./bin/rails generate controller Welcome index
./bin/rails generate controller Users
./bin/rails generate controller Disciplines
./bin/rails generate controller Exams
./bin/rails generate controller Assessments

# ajouter les modèles
./bin/rails generate model User \
userId:"$idtype" \
firstName:string \
lastName:string \
email:string \
secretHash:string \
teacher:boolean \
admin:boolean

./bin/rails generate model Discipline \
disciplineId:"$idtype" \
title:string \
startDate:date \
endDate:date

./bin/rails generate model Exam \
examId:"$idtype" \
examDate:date

./bin/rails generate model Assessment \
assessmentId:"$idtype" \
grade:real

# migration de la BDD
./bin/rails db:migrate
