**The first publication 'A physical basis for quantitative ChIP-seq' can be found at JBC [here.](https://pubmed.ncbi.nlm.nih.gov/32994221/) There is also an interactive web page devoted to the mathematical model [here.](http://proteinknowledge.com/siqD3/) A new object (and concept) called normalized coverage, and the basis for the codes below, were introduced in the latest siQ-ChIP paper [here.](https://www.nature.com/articles/s41598-023-34430-2).**  

# Intention
This repo exists to document a partial migration to a new version of siQ-ChIP and to facilitate reproduction of recent analysis in arabidopsis. 

The code here relies on the same core routines as the [standard siQ-ChIP repo](https://github.com/BradleyDickson/siQ-ChIP) but has been factored to match the newer perspective put forward in [this publication](https://www.nature.com/articles/s41598-023-34430-2). Equations below are written in LaTeX.

***Key updates are as follows***

1) Each *i*-th sequenced sample has its own concentration ```c_i = \frac{m_{i}}{660L_i(V_i)}``` where L_i is the average sequenced fragment length in sample *i* and V_i was its volume. This is either an IP volume or an input volume. As noted in the publication, this allows us to write an IP efficiency )alpha) as ```c_{ip}/c_{input}```. All concentration results are recorded in the output (stdout) from the run.

2) All the constants related to depth are now built into the Normalized Coverage. Normalized Coverage was introduced and defined in [this publication](https://www.nature.com/articles/s41598-023-34430-2). The normalized coverage is a probability density that we can use directly in calculations and we can visualize it as a sequencing track. The mass distriobition for a given sample is recovered as ```c_{i}t_{i}(x)``` where ```t_i(x)``` is the Normalized Coverage for sample *i* and ```c_{i}``` is the concentration of fragments in sample *i*. Normalized coverage are output as files with NC as their prefix.

3) The code computes all the concentrations and normalized coverage for all the involved samples (see below). With these objects built, peaks are called (relative to a uniform distribution of reads) and compared across all samples. All pairwise comparisons are constructed. P-values for peaks and cross sample comparisons are computed from confidence intervals provided by Method C of [Katz and company](https://www.jstor.org/stable/2530610). False discovery is controlled by Benjamini-Hochberg at 5%.

4) New files are generated, each named by the sample name with ```-DB``` or ```-pv``` appended at the end. The DB files are considered as database files and contain all the calculations from all comparisons. The pv files have been filtered so that significant comparisons can be extracted, typically via Awk. These files have explanitory headers. Each computed number in these files is the integral of Normalized Coverage over the interval defined by the first three entries on each line (chromosome, start, stop). By definition, this number is the number of sequenced fragments in the interval divided by the total number of sequenced fragments. This value can be compared across samples to understand their differences in distribution.

5) Normalized Coverage can be scaled to physical units by the product ```c_{i}t_{i}(x)```, which I typically do via Awk. There is also a script ```buildsiQtrack.sh``` that will build the IP efficiency track which was the main object in previous siQ-ChIP work. The first line of ```buildsiQtrack.sh```  explains how it needs to be run. This script scales an IP and input track by their respective ```c_{i}``` and computes the ratio of the IP and input tracks to return a new file with "siq" as the prefix. This script needs the genome length, as noted in the script.

6) The -DB tables make it easy to get a global measure of difference among the data. The distance between any pair of samples is computed here as the integral of the absoulte value of the difference between Norlamized Coverage of the samples. This is the L^1 distance. This is reported in a file l1-Table. I find it usefull to embed this table with diffusion maps, but you can also just look at the table as a heatmap.

# To run this code

Clone this repo and link all your bed files to the new cloned directory. Bed files should be ```sort -k1,1 -k2,2n``` sorted. Link all parameter files to this directory as well. Parameter files must be named as SAMPLE_NAME.params.in (where there must also be a SAMPLE_NAME.bed) and there must be one parameter file for each sample. It is easy to collect these in a spreadsheet and then use bash utilities to generate parameter files that conform to this name and format strategy.

- **Parameter files have a new format**:  Mass(ng) Volume(ul) ratio
- - Mass is the collected mass, volume is the volume that the same was in (ip or input), ratio is the ratio of ip to the sample. For an ip the ratio is 1, for an input the ratio is larger than one.
- An example IP and input parameter file: ```5.4 500 1``` for an IP and ```54.1 50 10``` for an input. 

With these prereqs satisfied, the code is run as ```./newMain.sh SAMPLE_1.bed SAMPLE_2.bed SAMPLE_3.bed SAMPLE_4.bed ...``` 

**It is assumed that you have N cpu for N samples**.

The arabidopsis data can be regenerated from sequencing outcomes and parameter files using:
~~~~
./newMain.sh WT_H2AZ_rep1_chr.bed WT_H2AZ_rep2_chr.bed WT_H2AZ_rep3_chr.bed WT_H3K27me3_rep1_chr.bed WT_H3K27me3_rep2_chr.bed WT_H3K27me3_rep3_chr.bed WT_H3K4me3_rep1_chr.bed WT_H3K4me3_rep2_chr.bed WT_H3K4me3_rep3_chr.bed hta_H2AZ_rep1_chr.bed hta_H2AZ_rep2_chr.bed hta_H2AZ_rep3_chr.bed hta_H3K27me3_rep1_chr.bed hta_H3K27me3_rep2_chr.bed hta_H3K27me3_rep3_chr.bed hta_H3K4me3_rep1_chr.bed hta_H3K4me3_rep2_chr.bed hta_H3K4me3_rep3_chr.bed WT_input_rep1_chr.bed WT_input_rep2_chr.bed WT_input_rep3_chr.bed hta_input_rep1_chr.bed hta_input_rep2_chr.bed hta_input_rep3_chr.bed
~~~~

# Known issue
Some environments format the output of ```ls -l``` differently. This code assumes that the 6-th field is the size of the file. If your ```ls -l``` puts file size in the 5-th field, please edit newMain.sh and change the lines that include ```ls -l``` to match your output field. 

# Parse outputs
The Normalized Coverage and converting to physical scale was covered above. Those scaled (or unscaled) bed files can be converted to bigwig and loaded into a genome browser. For finding specific peaks and for counting significant changes, etc, we need to parse the -DB or -pv files. A script to facilitate this in the arabidopsis data is included. The experiments had 3 replicates each and a user might want to, for example, find all peaks where a set of replicates agree with themselves but are distinct from some other sample. Selection of these sort of peaks is facilitated by the script Generate-Crosses.sh. Run this script as ```./Generate-Crosses.sh SAMPLE_NAME.bed``` and follow the prompts. The script will generate an Awk command that prints the peaks satisfying the information collected through the prompts. 

# Errors
Please check your outputs for error messages. Almost surely, any error will be due to bad sorting, bad formatting of inputs, or configuration of ```ls -l```.
