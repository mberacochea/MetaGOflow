#!/usr/bin/bash

About()
{
   printf "This script makes use of the fetch tool (https://github.com/EBI-Metagenomics/fetch_tool).\n"
   printf "to get the raw data that are about to be analysed by the EOSC-Life marine GOs workflow.\n"
   printf "Always remember that this is a single-sample-oriented workflow; thus, you need to download \n"
   printf "and run each sample separately in case you would like to analyse several samples."
   printf "          ******\n" 
}

Help()
{
   # Display Help
    printf "Options enabled: \n"
    printf "[-ru]   Run accession(s), whitespace separated. Use to download only certain project runs\n"
    printf "[--private]   Use when fetching private data\n"    
    printf "[-]   U\n"
}

# Parse arguments 
while getopts "h?:r:pu:k:" option; do
   case $option in
      h) # display Help
         About
         Help
         exit;;
      p) PRIVATE=${OPTARG};;
      r) RUN_ACCESSION_NUMBER=${OPTARG};;
      u) USER_NAME=${OPTARG};;
      k) USER_PASSWORD=${OPTARG};;
      ?) 
        printf "You may use the -h option for a thorough documentation.\n"
        exit;;
   esac
done

# Make the config file
CONF_FILE="fetchdata-config.json"
rm $CONF_FILE
printf '{
   "url_max_attempts": 5,
   "ena_api_username": "%s",
   "ena_api_password": "%s",
   "aspera_bin": "/app/fetch_tool/aspera-cli/cli/bin/ascp",
   "aspera_cert": "/app/fetch_tool/aspera-cli/cli/etc/asperaweb_id_dsa.openssh" 
}' $USER_NAME $USER_PASSWORD >> $CONF_FILE

# Run the fetch tool
if [[ $PRIVATE == "true" ]]; 
then
   printf "Getting private data..\n"
   fetch-read-tool --private -d raw_data_from_ENA/ -ru $RUN_ACCESSION_NUMBER -c $CONF_FILE
else
   printf "Getting publicly available data..\n"
   fetch-read-tool -d raw_data_from_ENA/ -ru $RUN_ACCESSION_NUMBER -c $CONF_FILE
fi
