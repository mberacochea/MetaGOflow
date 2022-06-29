#!/usr/bin/env python3

import argparse
from ruamel.yaml import YAML
import os
import yaml as yml


db_fields = [
    "ssu_db",
    "lsu_db",
    "ssu_tax",
    "lsu_tax",
    "ssu_otus",
    "lsu_otus",
    "rfam_models",
    "rfam_model_clans",
    "HMM_database_dir",
    "ko_file",
    "InterProScan_databases",
    "EggNOG_data_dir",
    "EggNOG_db",
    "EggNOG_diamond_db",
    "diamond_databaseFile",
    "Uniref90_db_txt",
    "go_config",
    "pathways_names",
    "pathways_classes",
    "graphs"
]


def db_dir(db_path, yaml_path):
    """Append databases path to values in template yaml"""
    if not db_path.endswith("/"):
        db_path += "/"
    with open(yaml_path) as f:
        yaml = YAML(typ="safe")
        doc = yaml.load(f)
        for db_field in db_fields:
            if isinstance(doc[db_field], (list, tuple)):
                for el in doc[db_field]:
                    el["path"] = os.path.join(db_path, el["path"])
            else:
                doc[db_field]["path"] = os.path.join(db_path, doc[db_field]["path"])
    return doc

if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description="Create the input.yml for the pipeline"
    )
    parser.add_argument(
        "-y", "--yml", dest="yml", help="YAML file with the constants", required=True
    )
    parser.add_argument(
        "-f", "--fr", dest="fr", help="Forward reads file path", required=False
    )
    parser.add_argument(
        "-r", "--rr", dest="rr", help="Reverse reads file path", required=False
    )
    parser.add_argument(
        "-o", "--output", dest="output", help="Output yaml file path", required=True
    )
    parser.add_argument(
        "-d",
        "--dbdir",
        dest="db_dir",
        help="Path to database directory",
        required=False,
    )

    args = parser.parse_args()

    print(f"Loading the constants from {args.yml}.")

    # load template yml file and append database path
    template_yml = db_dir(args.db_dir, args.yml)

    paired_reads = [args.fr.split("/")[-1].split(".fastq.gz")[0], args.rr.split("/")[-1].split(".fastq.gz")[0]]
    paired_reads_names = '"' + paired_reads[0] + '", "' + paired_reads[1] + '"'

    print("paired_reads: ", paired_reads)
    print("paired_reads_names: ", paired_reads_names)

    print("---------> Write the base .yml file.")
    with open(args.output, "w") as output_yml:
        
        yaml = YAML(typ="safe")

        yaml.dump(template_yml, output_yml)


    print("........ and edit the config .yml to add files")
    with open("config.yml", "r") as config_yml: 


        config = yml.safe_load(config_yml)

        config["forward_reads"] = {
            "class": "File",
            "format": "edam:format_1930",
            "path": args.fr,
        }

        config["reverse_reads"] = {
            "class": "File",
            "format": "edam:format_1930",
            "path": args.rr,
        }

    with open("eosc-wf.yml", "w") as config_yml:
        yaml.dump(config, config_yml)

    print("<--------- the .yml is now done")
