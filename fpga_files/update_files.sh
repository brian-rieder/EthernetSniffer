#!/bin/bash

# NOTE: This is Brian's script. It won't work for anyone else. That means you, Catie, stop snooping.

q_dir="/cygdrive/c/Users/Brian/QuartusQsys/demo_slave_only"
included_files=( "$q_dir/master_example.sv" "$q_dir/custom_slave.sv" "$q_dir/linux_app_sample/app.c" )

for f in "${included_files[@]}" ; do
   cp $f .
done

git add .

echo "Enter your commit message: "
read commit_message

git commit -m "$commit_message" .
git push .