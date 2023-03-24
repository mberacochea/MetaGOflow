#! /usr/bin/env python3

import sys
import argparse 
import textwrap
from rocrate.rocrate import ROCrate
from rocrate.model.person import Person

ena_accession_raw_data= "Raw sequence data and laboratory sequence generation metadata",

descriptions = [
    {
        "@id": "config.yml",
        "@type": "File",                 
        "name": "MetaGOflow configuration file",
        "description": "The configuration file through which the user sets the values of the metaGOflow parameters.",
        "encodingFormat": "text/yaml"
    },
    {
        "@id": "fastp.html",
        "@type": "File",                 
        "name": "FASTP analysis of raw sequence data",
        "description": "Quality control and preprocessing of FASTQ files",
        "encodingFormat": "text/html"
    },
    {
        "@id": "final.contigs.fa",
        "@type": "File",                 
        "name": "FASTA formatted contig sequences",
        "description": "These are the assembled contig sequences from the merged reads in FASTA format",
        "encodingFormat": "text/plain"
    },
    {
        "@id": "go.stats",
        "@type": "File",
        "name": "Geno Ontology summary statistics",
        "encodingFormat": "text/plain"
    },
    {
        "@id": "interproscan.stats",
        "@type": "File",
        "name": "InterProScan summary statistics",
        "encodingFormat": "text/plain"
    },
    {
        "@id": "ko.stats",
        "@type": "File",
        "name": "Kegg Ontology summary statistics",
        "encodingFormat": "text/plain"
    },
    {
        "@id": "orf.stats",
        "@type": "File",
        "name": "ORF summary statistics",
        "encodingFormat": "text/plain"
    },
    {
        "@id": "pfam.stats",
        "@type": "File",
        "name": "Pfam summary statistcs",
        "encodingFormat": "text/plain"
    },
    {
        "@id": ".merged_CDS.I5.tsv.gz",
        "@type": "File",
        "name": "Merged contigs CDS I5 summary",
        "encodingFormat": "application/zip"
    },
    {
        "@id": ".merged.hmm.tsv.gz",
        "@type": "File",
        "name": "Merged contigs HMM summary",
        "encodingFormat": "application/zip"
    },
    {
        "@id": ".merged.summary.go",
        "@type": "File",
        "name": "Merged contigs GO summary",
        "encodingFormat": "text/plain"
    },
    {
        "@id": ".merged.summary.go_slim",
        "@type": "File",
        "name": "Merged contigs InterProScan slim",
        "encodingFormat": "text/plain"
    },
    {
        "@id": ".merged.summary.ips",
        "@type": "File",
        "name": "Merged contigs InterProScan",
        "encodingFormat": "text/plain"
    },
    {
        "@id": ".merged.summary.ko",
        "@type": "File",
        "name": "Merged contigs KO summary",
        "encodingFormat": "text/plain"
    },
    {
        "@id": ".merged.summary.pfam",
        "@type": "File",
        "name": "Merged contigs PFAM summary",
        "encodingFormat": "text/plain"
    },
    {
        "@id": "RNA-counts",
        "@type": "File",
        "name": "Numbers of RNA's counted",
        "encodingFormat": "text/plain"
    },
    {
        "@id": "krona.html",
        "@type": "File",
        "name": "Krona summary of LSU taxonomic inventory",
        "encodingFormat": "application/html"
    },
    {
        "@id": ".merged_LSU.fasta.mseq.gz",
        "@type": "File",
        "name": "LSU sequences used for indentification",
        "encodingFormat": "application/zip"
    },
    {
        "@id": ".merged_LSU.fasta.mseq_hdf5.biom",
        "@type": "File",
        "name": "BIOM formatted hdf5 taxon counts for LSU sequences",
        "encodingFormat": "application/json-ld"
    },
    {
        "@id": ".merged_LSU.fasta.mseq_json.biom",
        "@type": "File",
        "name": "BIOM formatted taxon counts for LSU sequences",
        "encodingFormat": "application/json-ld"
    },
    {
        "@id": ".merged_LSU.fasta.mseq.tsv",
        "@type": "File",
        "name": "Tab-separated formatted taxon counts for LSU sequences",
        "encodingFormat": "application/json-ld"
    },
    {
        "@id": ".merged_LSU.fasta.mseq.txt",
        "@type": "File",
        "name": "Text-based taxon counts for LSU sequences",
        "encodingFormat": "application/json-ld"
    },
    {
        "@id": "krona.html",
        "@type": "File",
        "name": "Krona summary of SSU taxonomic inventory",
        "encodingFormat": "text/html"
    },
    {
        "@id": ".merged_SSU.fasta.mseq.gz",
        "@type": "File",
        "name": "LSU sequences used for indentification",
        "encodingFormat": "application/zip"
    },
    {
        "@id": ".merged_SSU.fasta.mseq_hdf5.biom",
        "@type": "File",
        "name": "BIOM formatted hdf5 taxon counts for SSU sequences",
        "encodingFormat": "application/json-ld"
    },
    {
        "@id": ".merged_SSU.fasta.mseq_json.biom",
        "@type": "File",
        "name": "BIOM formatted taxon counts for SSU sequences",
        "encodingFormat": "application/json-ld"
    },
    {
        "@id": ".merged_SSU.fasta.mseq.tsv",
        "@type": "File",
        "name": "Tab-separated formatted taxon counts for SSU sequences",
        "encodingFormat": "application/json-ld"
    },
    {
        "@id": ".merged_SSU.fasta.mseq.txt",
        "@type": "File",
        "name": "Text-based formatted taxon counts for SSU sequences",
        "encodingFormat": "application/json-ld"
    }
]




def main(target_directory, extended_config_yaml, ena_run_accession_id, metagoflow_version ):

    crate = ROCrate(target_directory) # here we use a complete directory, could we use just the json..?

    for entry in crate.get_entities():

        for description in descriptions:

            try:
                pk = description["@id"] in entry.id
            except:
                # new_crate.add(entry)
                pass
            finally:
                if pk :                    
                    for k,v in description.items():
                        if k not in entry.properties().keys():
                            entry.append_to(k, v)

    print("export...")

    crate.write_zip("exp_crate.zip")

    print(".. goodbye friend")


    sys.exit(0)


    metagoflow_id = "workflow/metaGOflow"
    license_id    = "https://www.apache.org/licenses/LICENSE-2.0"


    metagoflow_id = crate.add(Person(crate, metagoflow_id, properties={
        "@type": ["File", "SoftwareSourceCode", "ComputationalWorkflow"],
        "name": "metaGOflow",
        "affiliation": "University of Flatland", 
        "author": {"@id": "EMO BON"}, 
        "url": metagoflow_version,
        "license": { "@id": "https://www.apache.org/licenses/LICENSE-2.0"},
        "hasPart": [
            {"@id": "config.yml"},
            {"@id": "mini_dataset.yml"}
        ]
    }))

    license_id = crate.add(Person(crate, license_id, properties={
        "@type": "CreativeWork",
        "name": "Apache License 2.0"
    }))


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
            formatter_class=argparse.RawDescriptionHelpFormatter
            # description=textwrap.dedent(desc),
            )
    parser.add_argument("target_directory",
                        help="Name of target directory containing MetaGOflow" +\
                        "output"
                        )
    parser.add_argument("extended_config_yaml",
                        help="The extened YAML file metaGOflow built and used based on user's config" +\
                        "output"
                        )
    parser.add_argument("ena_run_accession_id",
                        help="Run accession id in ENA."
                        )
    parser.add_argument("metagoflow_version",
                        help="URL pointing to the metaGOflow version used"
                        )

    args = parser.parse_args()
    
    print(args.target_directory)

    main(args.target_directory, args.extended_config_yaml, args.ena_run_accession_id, args.metagoflow_version)




    """
    {
        "@id": "workflow/metaGOflow",  
        "@type": ["File", "SoftwareSourceCode", "ComputationalWorkflow"],
        "author": {"@id": "EMO BON"},
        "name": "metaGOflow",
        "description": "Metagenomics analysis based on MGnify for the needs of the EMO BON community",
        "license": { "@id": "https://www.apache.org/licenses/LICENSE-2.0"},
        "url": "https://www.imagemagick.org/",
        "hasPart": [
            {"@id": "config.yml"},
            {"@id": "mini_dataset.yml"}

        ] 
    },
    {
        "@id": "https://www.apache.org/licenses/LICENSE-2.0",
        "@type": "CreativeWork",
        "name": "Apache License 2.0"
    },
    """



