#!/bin/bash

# This script runs Qualimap RNA-Seq analysis on BAM files generated from RNA mapping
# and then generates a MultiQC report from the Qualimap output.
# Usage:
# bash 03_runQualimap_MultiQC.sh <input_bam_directory> <output_directory> <gtf_file>

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_bam_directory> <output_directory> <gtf_file>"
    exit 1
fi

# Assign command-line arguments to variables
INPATH=$1              # Path to directory containing BAM files
BASE_OUTPATH=$2        # Base output directory for Qualimap results
GTF_FILE=$3            # Path to GTF annotation file used during mapping

# Create output directory if it doesn't exist
mkdir -p "$BASE_OUTPATH"
chmod a+rwx "$BASE_OUTPATH"

# Loop through each BAM file in the input directory
for bam_file in "$INPATH"/*.bam; do
    filename=$(basename "$bam_file" .bam)   # Extract base filename without extension
    output_dir="$BASE_OUTPATH/$filename"    # Output directory for this sample

    # Run QualiMap RNA-Seq analysis
    echo "Running Qualimap for $bam_file..."
    qualimap rnaseq \
        -bam "$bam_file" \
        -gtf "$GTF_FILE" \
        -outdir "$output_dir" \
        -p non-strand-specific \
        -pe \
        --java-mem-size=7200M

    # Check if QualiMap completed successfully
    if [ $? -eq 0 ]; then
        echo "Qualimap completed for $filename."
    else
        echo "Qualimap failed for $filename."
    fi
done

# Running MultiQC on Qualimap output
echo "Running MultiQC on Qualimap output (forcing report overwrite with -f)..."
multiqc "$BASE_OUTPATH" -o "$BASE_OUTPATH" -f

# Check if MultiQC completed successfully
if [ $? -eq 0 ]; then
    echo "MultiQC analysis completed successfully. Results are stored in $BASE_OUTPATH."
else
    echo "MultiQC analysis failed."
fi

# Completion message
echo "Qualimap and MultiQC analysis complete! Results are stored in $BASE_OUTPATH."
