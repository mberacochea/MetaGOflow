#!/usr/bin/env python3

import argparse
from ruamel.yaml import YAML
import os

# RAW_READS_ANALYSIS = "raw-reads"
# ASSEMBLY_ANALYSIS = "assembly"
# AMPLICON_ANALYSIS = "amplicon"


db_fields = [
    "ssu_db",
    "lsu_db",
    "ssu_tax",
    "lsu_tax",
    "ssu_otus",
    "lsu_otus",
    "rfam_models",
    "rfam_model_clans",
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
        "-f", "--fr", dest="fr", help="forward reads file path", required=False
    )
    parser.add_argument(
        "-r", "--rr", dest="rr", help="reverse reads file path", required=False
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
    parser.add_argument(
        "-q",
        "--qc_rna_predct",
        help="Quality control step for the case of rna prediction",
        required=False,
    )
    parser.add_argument(
        "-a",
        "--assembly",
        help="Assembly of the pre-processed reads using MEGAHIT",
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

    with open(args.output, "w") as output_yml:
        
        print("---------> Write .yml file.")
        yaml = YAML(typ="safe")

        template_yml["forward_reads"] = {
            "class": "File",
            "format": "edam:format_1930",
            "path": args.fr,
        }

        template_yml["reverse_reads"] = {
            "class": "File",
            "format": "edam:format_1930",
            "path": args.rr,
        }

        if args.qc_rna_predct == "false": 
            template_yml["run_qc_rna_predict"] = False
        else:
            template_yml["run_qc_rna_predict"] = True

        if args.assembly == "false":
            template_yml["assembly"] = False
        else:
            template_yml["assembly"] = True

        yaml.dump(template_yml, output_yml)

        print("<--------- the .yml is now done")
