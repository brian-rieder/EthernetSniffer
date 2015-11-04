#!/bin/bash

module_name=$1
dir_to_place=$2

if [[ $# != 2 ]]; then
  echo "Usage: ./create_sv.sh <module_name> <dir_to_place>"
  exit 1
fi

if [[ -e $dir_to_place/$module_name.sv ]]; then
  echo "File already exists."
  exit 2
fi

if [[ ! -e $dir_to_place ]]; then
  echo "Directory '$dir_to_place' does not exist."
  exit 3
fi

todays_date=$(date +'%d %B %Y')

echo "// File name:   $module_name.sv
// Created:     $todays_date
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: $module_name

module $module_name
#(
  // parameter declaration
)
(
  // port declaration
);

endmodule" > $dir_to_place/$module_name.sv

exit 0
