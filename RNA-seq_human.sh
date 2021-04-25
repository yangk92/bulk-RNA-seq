#!/bin/bash
path=*********/Cleandata
trimmomatic=/data1/yangk/software/Trimmomatic-0.39/trimmomatic-0.39.jar
hisat2index=/data1/yangk/reference/human/hisat2/grch38_tran/genome_tran
GTFfile=/data1/yangk/reference/human/gencode.v28.annotation.gtf
cutadap=/data/yangk/miniconda2/envs/py35/bin/cutadapt
samtool=/usr/local/samtools/bin/samtools
core=50
cd $path
 mkdir log
for i in `ls |grep *********`;
do cd $path/$i
 $cutadap -j $core --pair-filter=any --minimum-length 15 --max-n 8 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o $path/$i/${i}_rmadp_R1.fq.gz -p $path/$i/${i}_rmadp_R2.fq.gz $path/$i/${i}_R1.fq.gz $path/${i}/${i}_R2.fq.gz >>$path/log/filter.txt 2>&1
 java -jar $trimmomatic PE -threads 22 -phred33 $path/${i}/${i}_rmadp_R1.fq.gz $path/${i}/${i}_rmadp_R2.fq.gz -baseout ${i}_fliter.fq.gz HEADCROP:8 LEADING:3 TRAILING:3 AVGQUAL:20 SLIDINGWINDOW:4:15 MINLEN:15 >>$path/log/filter.txt 2>&1
 hisat2 -p $core -x $hisat2index -1 $path/${i}/${i}_fliter_1P.fq.gz -2 $path/${i}/${i}_fliter_2P.fq.gz -S  $path/${i}/${i}.sam >>$path/log/hisat2.txt 2>&1
 samtools sort -@ $core -o $path/${i}/${i}.bam $path/${i}/${i}.sam >>$path/log/samtools.txt 2>&1
#  rm $path/${i}/${i}.sam
 samtools index $path/${i}/${i}.bam
# samtools view -@ $core -b $path/${i}/{i}.bam 1>$path/${i}/${i}_chr1.bam
# samtools index $path/${i}/${i}_chr1.bam
 featureCounts -T $core -t exon -g gene_id -a $GTFfile -o $path/${i}/${i}.count $path/${i}/${i}.bam >>$path/log/count.txt 2>&1
cd .. ;
done

